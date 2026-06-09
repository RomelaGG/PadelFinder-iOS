//
//  AvailabilityResponseDTO.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

struct AvailabilityResponseDTO: Decodable, Sendable {
    let companies: [AvailabilityCompanyDTO]
}

struct AvailabilityCompanyDTO: Decodable, Sendable {
    let id: String
    let name: String
    let website: String?
    let courts: [AvailabilityCourtDTO]
}

struct AvailabilityCourtDTO: Decodable, Sendable {
    let id: String
    let name: String
    let totalCourts: Int?
    let pricePerHour: Int?
    let imageUrl: String?
    let timeSlots: [AvailabilityTimeSlotDTO]
}

struct AvailabilityTimeSlotDTO: Decodable, Sendable {
    let time: String
    let status: String?
    let isBookable: Bool?
}
