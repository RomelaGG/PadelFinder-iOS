//
//  CompanyAvailabilityResponseDTO.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 17.06.26.
//

struct CompanyAvailabilityResponseDTO: Decodable, Equatable, Sendable {
    let date: String
    let company: AvailabilityCompanyDTO
}
