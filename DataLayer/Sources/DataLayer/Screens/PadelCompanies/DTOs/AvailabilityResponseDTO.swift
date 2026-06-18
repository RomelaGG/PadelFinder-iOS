//
//  AvailabilityResponseDTO.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

struct AvailabilityResponseDTO: Decodable, Equatable, Sendable {
    let date: String
    let companies: [AvailabilityCompanyDTO]
}

struct AvailabilityCompanyDTO: Decodable, Equatable, Sendable {
    let id: String
    let name: String
    let website: String?
    let logo: String?
    let coverImage: String?
    let courts: [AvailabilityCourtDTO]
}

struct AvailabilityCourtDTO: Decodable, Equatable, Sendable {
    let id: String
    let name: String
    let address: String?
    let pricePerHour: Int?
    let rating: Double?
    let totalCourts: Int
    let timeSlots: [AvailabilityTimeSlotDTO]
}

struct AvailabilityTimeSlotDTO: Decodable, Equatable, Sendable {
    let time: String
    let status: AvailabilityTimeSlotStatusDTO
    let isBookable: Bool
}

enum AvailabilityTimeSlotStatusDTO: String, Decodable, Equatable, Sendable {
    case available
    case booked
    case maintenance
}
