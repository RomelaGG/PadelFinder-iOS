//
//  PadelCourt.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

public struct PadelCourt: Equatable, Sendable {
    public let courtName: String
    public let id: String
    public let address: String?
    public let totalCourts: Int
    public let pricePerHour: Int?
    public let rating: Double?
    public let timeSlots: [TimeSlot]
    
    public init(
        courtName: String,
        id: String,
        address: String? = nil,
        totalCourts: Int = 0,
        pricePerHour: Int? = nil,
        rating: Double? = nil,
        timeSlotsArray: [TimeSlot]
    ) {
        self.courtName = courtName
        self.id = id
        self.address = address
        self.totalCourts = totalCourts
        self.pricePerHour = pricePerHour
        self.rating = rating
        self.timeSlots = timeSlotsArray
    }
}
