//
//  AvailabilityRepository.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import DomainLayer

final class AvailabilityRepository: AvailabilityRepositoryProtocol, @unchecked Sendable {
    private let remoteDataSource: any AvailabilityRemoteDataSourceProtocol

    init(remoteDataSource: any AvailabilityRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchAvailability(date: String) async throws -> [PadelCompany] {
        let response = try await remoteDataSource.fetchAvailability(date: date)
        return AvailabilityMapper.map(response)
    }
}
