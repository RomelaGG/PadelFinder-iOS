//
//  AvailabilityRepositoryProtocol.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

public protocol AvailabilityRepositoryProtocol: Sendable {
    func fetchAvailability(date: String) async throws -> [PadelCompany]
}
