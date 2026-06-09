//
//  FetchAvailabilityUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import CoreDI
import Swinject

public protocol FetchAvailabilityUseCaseProtocol: Sendable {
    func execute(date: String) async throws -> [PadelCompany]
}

struct FetchAvailabilityUseCase: FetchAvailabilityUseCaseProtocol {
    @Injected private var repository: any AvailabilityRepositoryProtocol

    func execute(date: String) async throws -> [PadelCompany] {
        try await repository.fetchAvailability(date: date)
    }
}
