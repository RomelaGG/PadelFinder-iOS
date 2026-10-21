//
//  SocialSignInModel.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 21.10.26.
//

import AuthenticationServices
import Combine
import CoreDI
import CoreUI
import DomainLayer
import SwiftUI

// MARK: - SocialSignInModel

/// Continue with Apple and Continue with Google, for all three screens that
/// offer them.
///
/// One object rather than three implementations: `WelcomeView` and
/// `SignInGateSheet` have no view model at all, and `SignInView`'s owns the
/// email form. Each screen keeps a `@StateObject` of this and decides for
/// itself what success means - which matters, because the gate sheet has no
/// `Navigator` in its environment and cannot route anywhere.
///
/// It is deliberately not folded into `SignInViewModel`. Apple's credential
/// arrives as two closures on Apple's own control, carrying
/// `ASAuthorizationAppleIDRequest` and `Result<ASAuthorization, Error>`;
/// routing those through an intent enum would put non-`Equatable`,
/// non-`Sendable` UIKit reference types into an enum that is otherwise all
/// value types, and would still leave the other two screens unserved.
@MainActor
final class SocialSignInModel: ObservableObject {

    /// Which button is mid-flight, so the other one can be left alone.
    @Published private(set) var busyProvider: AuthProvider?

    @Published private(set) var bannerMessage: String?
    @Published private(set) var bannerKind: PadelInlineBanner.Kind = .error

    /// Success. A published value rather than an `onSignedIn` closure: a
    /// closure would have to be handed over at `init`, and a `View` struct
    /// cannot capture its own `@State` or environment while building a
    /// `@StateObject`. The screen observes this instead.
    @Published private(set) var signedInUser: AuthUser?

    @Injected private var appleUseCase: any SignInWithAppleUseCaseProtocol
    @Injected private var googleUseCase: any SignInWithGoogleUseCaseProtocol
    @Injected private var googleCredentials: any GoogleCredentialProviding

    /// Held between Apple's `onRequest` and its `onCompletion`, which are two
    /// separate callbacks on the same control.
    private var pendingNonce: String?

    private var task: Task<Void, Never>?

    deinit {
        task?.cancel()
    }

    func isBusy(_ provider: AuthProvider) -> Bool {
        busyProvider == provider
    }

    var isBusy: Bool {
        busyProvider != nil
    }

    func clearBanner() {
        bannerMessage = nil
    }

    /// For the button a screen draws when `AuthFeatureFlags` has the provider
    /// switched off. Saying plainly that the option is not ready beats showing
    /// the provider's sheet and letting it fail.
    func showUnavailable(_ provider: AuthProvider) {
        show(AuthDomainError.socialSignInUnavailable(provider))
    }

    // MARK: Apple

    /// Passed to `PadelAppleButton(onRequest:)`.
    func configure(_ request: ASAuthorizationAppleIDRequest) {
        pendingNonce = AuthNonce.make()

        request.requestedScopes = [.fullName, .email]
        request.nonce = pendingNonce
    }

    /// Passed to `PadelAppleButton(onCompletion:)`.
    func completeApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authorization):
            startApple(with: authorization)

        case let .failure(error):
            // The nonce dies with the attempt either way.
            pendingNonce = nil

            guard !isAppleCancellation(error) else { return }

            show(error)
        }
    }

    // MARK: Google

    func signInWithGoogle() {
        guard busyProvider == nil else { return }

        // Checked here and not only in the use case: with the flag off the
        // use case would refuse *after* Google's sheet had already appeared
        // and been consented to, which is a worse answer than never opening
        // it.
        guard AuthFeatureFlags.isEnabled(.google) else {
            show(AuthDomainError.socialSignInUnavailable(.google))
            return
        }

        guard let nonce = AuthNonce.make() else {
            show(AuthDomainError.unknown)
            return
        }

        busyProvider = .google
        bannerMessage = nil

        task?.cancel()
        task = Task { [weak self] in
            await self?.performGoogleSignIn(nonce: nonce)
        }
    }
}

// MARK: - Private

private extension SocialSignInModel {

    // MARK: Apple

    func startApple(with authorization: ASAuthorization) {
        guard busyProvider == nil else { return }

        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let identityToken = String(data: tokenData, encoding: .utf8)
        else {
            pendingNonce = nil
            show(AuthDomainError.unknown)
            return
        }

        // Apple hands back the name only on the *first* authorization for this
        // Apple ID and app. Nil on every later sign-in is correct, not a bug:
        // the subject identifies the account, and `AccountLinker` never
        // overwrites a stored name with nil. To see the first-run path again,
        // revoke the app under Settings -> Apple Account -> Sign in with Apple.
        let displayName = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")

        let nonce = pendingNonce
        pendingNonce = nil

        busyProvider = .apple
        bannerMessage = nil

        task?.cancel()
        task = Task { [weak self] in
            await self?.performAppleSignIn(
                identityToken: identityToken,
                nonce: nonce,
                displayName: displayName.isEmpty ? nil : displayName
            )
        }
    }

    func performAppleSignIn(
        identityToken: String,
        nonce: String?,
        displayName: String?
    ) async {
        do {
            let user = try await appleUseCase.execute(
                identityToken: identityToken,
                nonce: nonce,
                displayName: displayName
            )

            try Task.checkCancellation()
            finish(with: user)
        } catch is CancellationError {
            busyProvider = nil
        } catch {
            fail(with: error)
        }
    }

    /// `ASAuthorizationError.canceled` only.
    ///
    /// Notably *not* `.unknown` (1000), which is what a Simulator with no
    /// Apple ID signed in throws, usually without showing a sheet at all.
    /// Swallowing that one would make the button look dead with nothing to
    /// debug.
    func isAppleCancellation(_ error: Error) -> Bool {
        guard let authorizationError = error as? ASAuthorizationError else { return false }

        return authorizationError.code == .canceled
    }

    // MARK: Google

    func performGoogleSignIn(nonce: String) async {
        do {
            guard let identityToken = try await googleCredentials.identityToken(nonce: nonce) else {
                // Cancelled. Nothing to say.
                busyProvider = nil
                return
            }

            try Task.checkCancellation()

            let user = try await googleUseCase.execute(
                identityToken: identityToken,
                nonce: nonce
            )

            try Task.checkCancellation()
            finish(with: user)
        } catch is CancellationError {
            busyProvider = nil
        } catch {
            fail(with: error)
        }
    }

    // MARK: Shared

    func finish(with user: AuthUser) {
        busyProvider = nil
        signedInUser = user
    }

    func fail(with error: Error) {
        busyProvider = nil

        guard !Task.isCancelled else { return }

        show(error)
    }

    func show(_ error: Error) {
        let domainError = error as? AuthDomainError

        bannerKind = domainError.map { $0.isRateLimit ? .warning : .error } ?? .error
        bannerMessage = domainError?.localizedDescription ?? AuthCopy.Error.generic
    }
}
