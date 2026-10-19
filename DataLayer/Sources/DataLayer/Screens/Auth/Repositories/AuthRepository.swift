//
//  AuthRepository.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI
import CoreNetworking
import DomainLayer

/// The one owner of the invariant "the stored tokens and the published session
/// always agree".
///
/// Every path that mints a token does the same two things in the same order -
/// persist, then publish - so there is no way for the app to believe somebody
/// is signed in while the Keychain says otherwise.
final class AuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    @Injected private var dataSource: any AuthRemoteDataSourceProtocol
    @Injected private var mapper: any AuthMapperProtocol
    @Injected private var errorMapper: any AuthErrorMapperProtocol
    @Injected private var tokenStore: TokenStore
    @Injected private var authSession: AuthSession

    // MARK: - Email and password

    func register(email: String, password: String, displayName: String?) async throws {
        _ = try await mapping {
            try await dataSource.register(
                email: email,
                password: password,
                displayName: displayName
            )
        }
    }

    func verifyEmailCode(email: String, code: String) async throws -> AuthUser {
        let dto = try await mapping {
            try await dataSource.verifyOTP(email: email, code: code)
        }

        return await adopt(dto)
    }

    func resendCode(email: String, purpose: OTPPurpose) async throws {
        _ = try await mapping {
            switch purpose {
            case .verifyEmail:
                return try await dataSource.resendOTP(email: email)
            case .resetPassword:
                return try await dataSource.forgotPassword(email: email)
            }
        }
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        let dto = try await mapping {
            try await dataSource.login(email: email, password: password)
        }

        return await adopt(dto)
    }

    // MARK: - Providers

    func signInWithApple(
        identityToken: String,
        nonce: String?,
        displayName: String?
    ) async throws -> AuthUser {
        let dto = try await mapping {
            try await dataSource.signInWithApple(
                identityToken: identityToken,
                nonce: nonce,
                displayName: displayName
            )
        }

        return await adopt(dto)
    }

    func signInWithGoogle(identityToken: String, nonce: String?) async throws -> AuthUser {
        let dto = try await mapping {
            try await dataSource.signInWithGoogle(identityToken: identityToken, nonce: nonce)
        }

        return await adopt(dto)
    }

    // MARK: - Password reset

    func requestPasswordReset(email: String) async throws {
        _ = try await mapping {
            try await dataSource.forgotPassword(email: email)
        }
    }

    /// Saves the password, then signs in with it.
    ///
    /// The reset endpoint answers 204 and revokes every session, so there is
    /// nothing to sign in *with* afterwards except the password the user has
    /// just chosen - which is still in memory at this exact moment. One extra
    /// round trip is what lets the screen keep its promise instead of dropping
    /// the user back at a sign-in form it told them they would not see.
    func resetPassword(email: String, code: String, newPassword: String) async throws -> AuthUser {
        // Every session is about to be revoked server-side, so the local one
        // is already worthless. Cleared without publishing a sign-out: the
        // sign-in below is about to publish the real answer, and a flash of
        // the signed-out UI in between would be a lie.
        await tokenStore.clear(notifying: false)

        try await mapping {
            try await dataSource.resetPassword(
                email: email,
                code: code,
                newPassword: newPassword
            )
        }

        do {
            return try await signIn(email: email, password: newPassword)
        } catch {
            throw AuthDomainError.passwordSavedButSignInFailed
        }
    }

    // MARK: - Session

    func signOut() async {
        if let refreshToken = await tokenStore.refreshToken() {
            // Best effort. A device that cannot reach the server must still
            // end up signed out locally.
            try? await dataSource.logout(refreshToken: refreshToken)
        }

        await tokenStore.clear(notifying: true)
    }

    func deleteAccount() async throws {
        try await mapping {
            try await dataSource.deleteAccount()
        }

        await tokenStore.clear(notifying: true)
    }

    func restoreSession() async {
        guard let cached = await tokenStore.restore() else {
            await authSession.signedOut()
            return
        }

        // Published straight from the Keychain, before any network call. This
        // is what keeps `.unknown` to a single frame: waiting for `/auth/me`
        // would park the Account tab on a spinner for the full request
        // timeout every time the connection is poor.
        await authSession.signedIn(cached)

        // Then validate and freshen. A failure here is deliberately ignored:
        // a dead token has already signed the user out inside the token store,
        // and anything else means they stay signed in offline.
        _ = try? await fetchCurrentUser()
    }

    func fetchCurrentUser() async throws -> AuthUser {
        let dto = try await mapping {
            try await dataSource.currentUser()
        }

        let user = mapper.mapUser(dto)

        await tokenStore.update(user: user)
        await authSession.updateUser(user)

        return user
    }

    func updateProfile(displayName: String?, phone: String?) async throws -> AuthUser {
        let dto = try await mapping {
            try await dataSource.updateProfile(displayName: displayName, phone: phone)
        }

        let user = mapper.mapUser(dto)

        await tokenStore.update(user: user)
        await authSession.updateUser(user)

        return user
    }
}

// MARK: - Private

private extension AuthRepository {

    /// Persist, then publish. Always in that order, from one place.
    func adopt(_ dto: TokenResponseDTO) async -> AuthUser {
        let user = mapper.mapUser(dto.user)
        let tokens = mapper.mapTokens(dto)

        await tokenStore.store(tokens: tokens, user: user)
        await authSession.signedIn(user)

        return user
    }

    /// Turns transport failures into domain ones.
    ///
    /// `CancellationError` and anything already an `AuthDomainError` fall
    /// through untouched - a cancelled request is not a failure the user
    /// needs told about.
    func mapping<T>(_ body: () async throws -> T) async throws -> T {
        do {
            return try await body()
        } catch let error as NetworkError {
            throw errorMapper.map(error)
        }
    }
}
