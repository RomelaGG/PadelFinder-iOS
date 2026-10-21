//
//  GoogleSignInCredentialProvider.swift
//  CoreSocialAuth
//
//  Created by Giorgi Romelashvili on 21.10.26.
//

import DomainLayer
import Foundation
import GoogleSignIn

/// `GoogleCredentialProviding` on top of Google's own SDK.
///
/// It is used for exactly one thing: getting a single `id_token` to hand to
/// `POST /auth/google`. Everything else the SDK offers - a refreshable Google
/// session, scope upgrades, keychain-backed restore - we deliberately do not
/// want, because the app already has one session of record in `AuthSession`
/// and the Keychain token store, and a second one next to it can only drift.
/// Hence the `signOut()` at the end and no `restorePreviousSignIn` anywhere.
@MainActor
final class GoogleSignInCredentialProvider: GoogleCredentialProviding {

    /// Read from `GIDClientID` in the app's Info.plist, next to the reversed
    /// form of the same id in `CFBundleURLSchemes` - the two have to agree,
    /// and keeping them in one file is what makes a mismatch visible.
    private let clientID: String?

    /// `nonisolated` so the DI container can build this off the main actor,
    /// the same way `AuthPresenter` is registered. Reading one Info.plist key
    /// touches nothing that needs isolating.
    nonisolated init(bundle: Bundle = .main) {
        self.clientID = bundle.object(forInfoDictionaryKey: "GIDClientID") as? String
    }

    func identityToken(nonce: String) async throws -> String? {
        guard let clientID, !clientID.isEmpty else {
            throw SocialCredentialError.notConfigured
        }

        guard let presenter = TopViewController.find() else {
            throw SocialCredentialError.noPresenter
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: presenter,
                hint: nil,
                additionalScopes: nil,
                nonce: nonce
            )

            // Drop Google's own session straight away; we keep only the token.
            GIDSignIn.sharedInstance.signOut()

            // `idToken` is optional, and a missing one is a failure, not a
            // cancellation - it must not come back as `nil` from here.
            guard let identityToken = result.user.idToken?.tokenString else {
                throw SocialCredentialError.missingIdentityToken
            }

            return identityToken
        } catch let error as GIDSignInError where error.code == .canceled {
            return nil
        }
    }
}
