//
//  RegisterUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

public protocol RegisterUseCaseProtocol: Sendable {
    func execute(email: String, password: String, displayName: String?) async throws
}

struct RegisterUseCase: RegisterUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute(email: String, password: String, displayName: String?) async throws {
        try await repository.register(email: email, password: password, displayName: displayName)
    }
}
