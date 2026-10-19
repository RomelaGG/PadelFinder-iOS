//
//  SignInUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

public protocol SignInUseCaseProtocol: Sendable {
    func execute(email: String, password: String) async throws -> AuthUser
}

struct SignInUseCase: SignInUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute(email: String, password: String) async throws -> AuthUser {
        try await repository.signIn(email: email, password: password)
    }
}
