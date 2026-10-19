//
//  VerifyCodeViewModel.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Combine
import CoreDI
import CoreUI
import DomainLayer
import SwiftUI

// MARK: - State

struct VerifyCodeViewModelState {
    let email: String
    let purpose: OTPPurpose

    var code = ""
    var hasError = false
    var isCodeEntryEnabled = true

    var bannerMessage: String?
    var bannerKind: PadelInlineBanner.Kind = .error

    var isSubmitting = false

    /// Seconds until Resend becomes available. Dropped to zero the moment the
    /// code the user holds is dead, so the way out is immediately there.
    var secondsRemaining = 0

    var route: AuthRoute?

    var title: String {
        purpose == .verifyEmail ? AuthCopy.OTP.title : AuthCopy.OTP.titleReset
    }

    var subtitle: String {
        AuthCopy.OTP.subtitle(email)
    }
}

// MARK: - Intent

enum VerifyCodeViewModelIntent {
    case appeared
    case codeChanged(String)
    case codeCompleted(String)
    case resendTapped
    case changeEmailTapped
    case signInTapped
    case routeHandled
}

// MARK: - ViewModel

@MainActor
final class VerifyCodeViewModel: ObservableObject, FormBindable {

    /// Not a server rule - the backend has no per-request cooldown at all,
    /// only an hourly cap. This is a client-side pause so a frustrated user
    /// cannot burn their five sends an hour in five seconds.
    private static let resendCooldown = 60

    @Published private(set) var state: VerifyCodeViewModelState

    @Injected private var verifyEmailCodeUseCase: any VerifyEmailCodeUseCaseProtocol
    @Injected private var resendCodeUseCase: any ResendCodeUseCaseProtocol

    private var submitTask: Task<Void, Never>?
    private var resendTask: Task<Void, Never>?
    private var countdownTask: Task<Void, Never>?
    private var submitGeneration = 0
    private var hasStarted = false

    init(state: VerifyCodeViewModelState) {
        self.state = state
    }

    deinit {
        submitTask?.cancel()
        resendTask?.cancel()
        countdownTask?.cancel()
    }

    func handleIntent(_ intent: VerifyCodeViewModelIntent) {
        switch intent {
        case .appeared:
            start()

        case let .codeChanged(code):
            state.code = code

            // An empty value is the OTP field clearing itself after a wrong
            // code, not the user typing. The error stays visible until a real
            // digit arrives.
            if !code.isEmpty {
                state.hasError = false
                state.bannerMessage = nil
            }

        case let .codeCompleted(code):
            submit(code: code)

        case .resendTapped:
            resend()

        case .changeEmailTapped:
            state.route = .pop

        case .signInTapped:
            state.route = .replace(.signIn(email: state.email))

        case .routeHandled:
            state.route = nil
        }
    }
}

// MARK: - Private

private extension VerifyCodeViewModel {

    func start() {
        guard !hasStarted else { return }

        hasStarted = true
        startCountdown()
    }

    func submit(code: String) {
        guard !state.isSubmitting, state.isCodeEntryEnabled else { return }

        guard code.count == 6 else {
            state.bannerMessage = AuthCopy.Error.incompleteCode
            return
        }

        // A reset code has no endpoint that can check it on its own: it is
        // spent by `/auth/password/reset` along with the new password. So this
        // step only confirms six digits were entered and moves on, and a wrong
        // code surfaces on the next screen.
        guard state.purpose.isVerifiableOnItsOwn else {
            state.route = .replace(.newPassword(email: state.email, code: code))
            return
        }

        submitGeneration += 1
        let generation = submitGeneration

        submitTask?.cancel()
        submitTask = Task { [weak self] in
            await self?.performVerify(code: code, generation: generation)
        }
    }

    func performVerify(code: String, generation: Int) async {
        state.isSubmitting = true
        state.bannerMessage = nil

        do {
            let user = try await verifyEmailCodeUseCase.execute(email: state.email, code: code)

            try Task.checkCancellation()
            guard generation == submitGeneration else { return }

            // Replaced, not pushed: the code has been spent and going back to
            // it would land on a dead one.
            state.route = .replace(.success(email: user.email))
        } catch is CancellationError {
            return
        } catch {
            guard generation == submitGeneration, !Task.isCancelled else { return }

            handle(error)
        }

        state.isSubmitting = false
    }

    func resend() {
        guard state.secondsRemaining == 0 else { return }

        resendTask?.cancel()
        resendTask = Task { [weak self] in
            await self?.performResend()
        }
    }

    func performResend() async {
        state.bannerMessage = nil

        do {
            try await resendCodeUseCase.execute(email: state.email, purpose: state.purpose)

            try Task.checkCancellation()

            state.code = ""
            state.hasError = false
            state.isCodeEntryEnabled = true
            state.bannerKind = .success
            state.bannerMessage = AuthCopy.OTP.resent

            startCountdown()
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }

            handle(error)
        }
    }

    func handle(_ error: Error) {
        guard let domainError = error as? AuthDomainError else {
            state.bannerKind = .error
            state.bannerMessage = AuthCopy.Error.generic
            return
        }

        state.bannerKind = domainError.isRateLimit ? .warning : .error
        state.bannerMessage = domainError.localizedDescription

        switch domainError {
        case .invalidCode:
            // Shake, clear, refocus. The server's sentence carries the number
            // of attempts left, which is why it is shown rather than rewritten.
            state.hasError = true
            stopCountdown()

        case .codeBurned:
            // Five wrong tries and the code is dead. The field is disabled so
            // the user stops guessing, and Resend is available at once.
            state.hasError = true
            state.isCodeEntryEnabled = false
            stopCountdown()

        case .sessionExpired:
            state.route = .dismissFlow

        default:
            break
        }
    }

    // MARK: Countdown

    /// Driven here rather than by a `Timer` in the view: a timer inside a view
    /// keeps running while the app is backgrounded and dies when the view goes
    /// away, neither of which is what a cooldown means.
    func startCountdown() {
        countdownTask?.cancel()
        state.secondsRemaining = Self.resendCooldown

        countdownTask = Task { [weak self] in
            while await self?.state.secondsRemaining ?? 0 > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                guard !Task.isCancelled else { return }

                await self?.tick()
            }
        }
    }

    func tick() {
        guard state.secondsRemaining > 0 else { return }

        state.secondsRemaining -= 1
    }

    func stopCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
        state.secondsRemaining = 0
    }
}
