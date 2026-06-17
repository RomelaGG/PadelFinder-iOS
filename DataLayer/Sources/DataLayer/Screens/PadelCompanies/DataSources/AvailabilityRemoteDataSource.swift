//
//  AvailabilityRemoteDataSource.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import CoreDI
import CoreNetworking

protocol AvailabilityRemoteDataSourceProtocol: Sendable {
    func fetchAvailability(date: String) async throws -> AvailabilityResponseDTO
    func fetchCompanyAvailability(companyId: String, date: String) async throws -> CompanyAvailabilityResponseDTO
}

final class AvailabilityRemoteDataSource: AvailabilityRemoteDataSourceProtocol, @unchecked Sendable {
    @Injected private var networkManager: NetworkManager

    func fetchAvailability(date: String) async throws -> AvailabilityResponseDTO {
        try await networkManager.send(AvailabilityRequest(date: date))
    }

    func fetchCompanyAvailability(companyId: String, date: String) async throws -> CompanyAvailabilityResponseDTO {
        try await networkManager.send(CompanyAvailabilityRequest(companyId: companyId, date: date))
    }
}
