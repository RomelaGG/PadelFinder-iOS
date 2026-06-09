//
//  PadelCourt.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

public struct PadelCourt: Sendable {
    public let courtName: String
    public let id: String
    public let totalCourts: Int?
    public let pricePerHour: Int?
    public let imageURL: String?
    public let timeSlots: [TimeSlot]
    
    public init(
        courtName: String,
        id: String,
        totalCourts: Int? = nil,
        pricePerHour: Int? = nil,
        imageURL: String? = nil,
        timeSlotsArray: [TimeSlot]
    ) {
        self.courtName = courtName
        self.id = id
        self.totalCourts = totalCourts
        self.pricePerHour = pricePerHour
        self.imageURL = imageURL
        self.timeSlots = timeSlotsArray
    }
}
