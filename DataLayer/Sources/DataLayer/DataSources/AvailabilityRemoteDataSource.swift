//
//  AvailabilityRemoteDataSource.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import PadelFinderCoreServices

protocol AvailabilityRemoteDataSourceProtocol: Sendable {
    func fetchAvailability(date: String) async throws -> AvailabilityResponseDTO
}

final class AvailabilityRemoteDataSource: AvailabilityRemoteDataSourceProtocol, @unchecked Sendable {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func fetchAvailability(date: String) async throws -> AvailabilityResponseDTO {
        try await networkManager.send(AvailabilityRequest(date: date))
    }
}
