//
//  AvailabilityMapper.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import DomainLayer

protocol AvailabilityMapperProtocol: Sendable {
    func map(_ response: AvailabilityResponseDTO) -> [PadelCompany]
    func mapCompany(_ response: CompanyAvailabilityResponseDTO) -> PadelCompany
}

struct AvailabilityMapper: AvailabilityMapperProtocol, Sendable {
    func map(_ response: AvailabilityResponseDTO) -> [PadelCompany] {
        response.companies.map(mapCompany)
    }

    func mapCompany(_ response: CompanyAvailabilityResponseDTO) -> PadelCompany {
        mapCompany(response.company)
    }

    private func mapCompany(_ company: AvailabilityCompanyDTO) -> PadelCompany {
        PadelCompany(
            companyName: company.name,
            companyID: company.id,
            companyWebsite: company.website,
            companyLogo: company.logo,
            companyCourts: company.courts.map(mapCourt)
        )
    }

    private func mapCourt(_ court: AvailabilityCourtDTO) -> PadelCourt {
        PadelCourt(
            courtName: court.name,
            id: court.id,
            totalCourts: court.totalCourts,
            pricePerHour: court.pricePerHour,
            imageURL: court.imageUrl,
            timeSlotsArray: court.timeSlots.map(mapTimeSlot)
        )
    }

    private func mapTimeSlot(_ slot: AvailabilityTimeSlotDTO) -> TimeSlot {
        TimeSlot(
            startingTime: slot.time,
            availability: slot.isBookable ?? (slot.status == "available")
        )
    }
}
