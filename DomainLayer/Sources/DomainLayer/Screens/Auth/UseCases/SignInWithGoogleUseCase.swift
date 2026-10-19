//
//  SignInWithGoogleUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

public protocol SignInWithGoogleUseCaseProtocol: Sendable {
    func execute(identityToken: String, nonce: String?) async throws -> AuthUser
}

struct SignInWithGoogleUseCase: SignInWithGoogleUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute(identityToken: String, nonce: String?) async throws -> AuthUser {
        guard AuthFeatureFlags.googleSignInEnabled else {
            throw AuthDomainError.socialSignInUnavailable(.google)
        }

        return try await repository.signInWithGoogle(
            identityToken: identityToken,
            nonce: nonce
        )
    }
}
