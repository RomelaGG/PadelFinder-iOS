//
//  FetchAvailabilityUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

public protocol FetchAvailabilityUseCaseProtocol: Sendable {
    func execute(date: String) async throws -> [PadelCompany]
}

public struct FetchAvailabilityUseCase: FetchAvailabilityUseCaseProtocol {
    private let repository: any AvailabilityRepositoryProtocol

    public init(repository: any AvailabilityRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(date: String) async throws -> [PadelCompany] {
        try await repository.fetchAvailability(date: date)
    }
}
