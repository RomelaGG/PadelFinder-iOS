//
//  AvailabilityRepository.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import DomainLayer
import CoreDI

final class AvailabilityRepository: AvailabilityRepositoryProtocol, @unchecked Sendable {
    @Injected private var remoteDataSource: any AvailabilityRemoteDataSourceProtocol
    @Injected private var mapper: any AvailabilityMapperProtocol

    func fetchAvailability(date: String) async throws -> [PadelCompany] {
        let response = try await remoteDataSource.fetchAvailability(date: date)
        return mapper.map(response)
    }
}
