//
//  UpdateProfileUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

public protocol UpdateProfileUseCaseProtocol: Sendable {
    func execute(displayName: String?, phone: String?) async throws -> AuthUser
}

struct UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute(displayName: String?, phone: String?) async throws -> AuthUser {
        try await repository.updateProfile(displayName: displayName, phone: phone)
    }
}
