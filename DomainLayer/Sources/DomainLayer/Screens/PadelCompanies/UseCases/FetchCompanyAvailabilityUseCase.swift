//
//  FetchCompanyAvailabilityUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 17.06.26.
//

import CoreDI
import Swinject

public protocol FetchCompanyAvailabilityUseCaseProtocol: Sendable {
    func execute(companyId: String, date: String) async throws -> PadelCompany
}

struct FetchCompanyAvailabilityUseCase: FetchCompanyAvailabilityUseCaseProtocol {
    @Injected private var repository: any AvailabilityRepositoryProtocol

    func execute(companyId: String, date: String) async throws -> PadelCompany {
        try await repository.fetchCompanyAvailability(companyId: companyId, date: date)
    }
}
