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
}

final class AvailabilityRemoteDataSource: AvailabilityRemoteDataSourceProtocol, @unchecked Sendable {
    @Injected private var networkManager: NetworkManager

    func fetchAvailability(date: String) async throws -> AvailabilityResponseDTO {
        try await networkManager.send(AvailabilityRequest(date: date))
    }
}
