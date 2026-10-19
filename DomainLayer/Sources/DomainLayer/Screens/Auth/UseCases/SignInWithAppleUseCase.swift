//
//  SignInWithAppleUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

public protocol SignInWithAppleUseCaseProtocol: Sendable {
    func execute(identityToken: String, nonce: String?, displayName: String?) async throws -> AuthUser
}

struct SignInWithAppleUseCase: SignInWithAppleUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute(
        identityToken: String,
        nonce: String?,
        displayName: String?
    ) async throws -> AuthUser {
        // Refused before any network call while the feature is off: the server
        // would answer `provider_not_configured`, and a 503 is a worse way to
        // learn this than a sentence saying so.
        guard AuthFeatureFlags.appleSignInEnabled else {
            throw AuthDomainError.socialSignInUnavailable(.apple)
        }

        return try await repository.signInWithApple(
            identityToken: identityToken,
            nonce: nonce,
            displayName: displayName
        )
    }
}
