//
//  ResetPasswordUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

public protocol ResetPasswordUseCaseProtocol: Sendable {
    func execute(email: String, code: String, newPassword: String) async throws -> AuthUser
}

struct ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute(email: String, code: String, newPassword: String) async throws -> AuthUser {
        try await repository.resetPassword(
            email: email,
            code: code,
            newPassword: newPassword
        )
    }
}
