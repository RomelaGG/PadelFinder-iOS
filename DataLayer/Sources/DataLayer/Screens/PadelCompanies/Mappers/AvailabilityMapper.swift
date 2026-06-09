//
//  AvailabilityMapper.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import DomainLayer

enum AvailabilityMapper {
    static func map(_ response: AvailabilityResponseDTO) -> [PadelCompany] {
        response.companies.map { company in
            PadelCompany(
                companyName: company.name,
                companyID: company.id,
                companyWebsite: company.website,
                companyCourts: company.courts.map(mapCourt)
            )
        }
    }

    private static func mapCourt(_ court: AvailabilityCourtDTO) -> PadelCourt {
        PadelCourt(
            courtName: court.name,
            id: court.id,
            totalCourts: court.totalCourts,
            pricePerHour: court.pricePerHour,
            imageURL: court.imageUrl,
            timeSlotsArray: court.timeSlots.map(mapTimeSlot)
        )
    }

    private static func mapTimeSlot(_ slot: AvailabilityTimeSlotDTO) -> TimeSlot {
        TimeSlot(
            startingTime: slot.time,
            availability: slot.isBookable ?? (slot.status == "available")
        )
    }
}
