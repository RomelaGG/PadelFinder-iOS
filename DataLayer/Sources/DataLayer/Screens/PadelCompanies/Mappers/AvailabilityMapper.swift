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
            companyCoverImage: company.coverImage,
            companyCourts: company.courts.map(mapCourt)
        )
    }

    private func mapCourt(_ court: AvailabilityCourtDTO) -> PadelCourt {
        PadelCourt(
            courtName: court.name,
            id: court.id,
            address: court.address,
            totalCourts: court.totalCourts,
            pricePerHour: court.pricePerHour,
            rating: court.rating,
            timeSlotsArray: court.timeSlots.map(mapTimeSlot)
        )
    }

    private func mapTimeSlot(_ slot: AvailabilityTimeSlotDTO) -> TimeSlot {
        TimeSlot(
            startingTime: slot.time,
            status: mapTimeSlotStatus(slot.status),
            isBookable: slot.isBookable
        )
    }

    private func mapTimeSlotStatus(_ status: AvailabilityTimeSlotStatusDTO) -> TimeSlotStatus {
        switch status {
        case .available:
            return .available
        case .booked:
            return .booked
        case .maintenance:
            return .maintenance
        }
    }
}
