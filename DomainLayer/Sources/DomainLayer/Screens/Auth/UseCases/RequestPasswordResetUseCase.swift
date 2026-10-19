//
//  RequestPasswordResetUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

/// Asks for a reset code.
///
/// Answers the same way whether or not the address has an account, so the
/// screen must always advance to the code step. Branching on the result would
/// turn this into a way to test whether somebody is registered.
public protocol RequestPasswordResetUseCaseProtocol: Sendable {
    func execute(email: String) async throws
}

struct RequestPasswordResetUseCase: RequestPasswordResetUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute(email: String) async throws {
        try await repository.requestPasswordReset(email: email)
    }
}
