//
//  DeleteAccountUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

public protocol DeleteAccountUseCaseProtocol: Sendable {
    func execute() async throws
}

struct DeleteAccountUseCase: DeleteAccountUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute() async throws {
        try await repository.deleteAccount()
    }
}
