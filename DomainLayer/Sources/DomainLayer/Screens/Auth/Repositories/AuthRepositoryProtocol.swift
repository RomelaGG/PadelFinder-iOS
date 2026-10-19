//
//  AuthRepositoryProtocol.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// Everything the app can do with an account.
///
/// Note what is missing: no method returns `AuthTokens`. Tokens are the data
/// layer's business — they go straight into the Keychain and the token store,
/// and nothing above this line can hold one, let alone leak one into a log.
public protocol AuthRepositoryProtocol: Sendable {

    // MARK: Email and password

    /// Starts sign-up. Always succeeds from the caller's point of view: the
    /// server answers 202 whether or not the address is already taken, so that
    /// this endpoint cannot be used to find out who has an account.
    func register(email: String, password: String, displayName: String?) async throws

    func verifyEmailCode(email: String, code: String) async throws -> AuthUser

    func resendCode(email: String, purpose: OTPPurpose) async throws

    func signIn(email: String, password: String) async throws -> AuthUser

    // MARK: Providers

    func signInWithApple(
        identityToken: String,
        nonce: String?,
        displayName: String?
    ) async throws -> AuthUser

    func signInWithGoogle(identityToken: String, nonce: String?) async throws -> AuthUser

    // MARK: Password reset

    func requestPasswordReset(email: String) async throws

    /// Saves the new password and signs the user in with it.
    ///
    /// The reset endpoint itself returns no tokens and revokes every existing
    /// session, so the sign-in is chained here — which is what lets the screen
    /// honestly promise "You'll be signed in once it's saved."
    func resetPassword(email: String, code: String, newPassword: String) async throws -> AuthUser

    // MARK: Session

    /// Best-effort by design: a failed call to the server must still sign the
    /// user out of this device.
    func signOut() async

    func deleteAccount() async throws

    /// Reads the Keychain and publishes whatever it finds. Never throws, and
    /// safe to call more than once.
    func restoreSession() async

    func fetchCurrentUser() async throws -> AuthUser

    func updateProfile(displayName: String?, phone: String?) async throws -> AuthUser
}
