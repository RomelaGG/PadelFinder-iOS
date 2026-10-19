//
//  FetchCurrentUserUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

public protocol FetchCurrentUserUseCaseProtocol: Sendable {
    func execute() async throws -> AuthUser
}

struct FetchCurrentUserUseCase: FetchCurrentUserUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute() async throws -> AuthUser {
        try await repository.fetchCurrentUser()
    }
}
