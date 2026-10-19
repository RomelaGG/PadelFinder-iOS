//
//  VerifyEmailCodeUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

public protocol VerifyEmailCodeUseCaseProtocol: Sendable {
    func execute(email: String, code: String) async throws -> AuthUser
}

struct VerifyEmailCodeUseCase: VerifyEmailCodeUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute(email: String, code: String) async throws -> AuthUser {
        try await repository.verifyEmailCode(email: email, code: code)
    }
}
