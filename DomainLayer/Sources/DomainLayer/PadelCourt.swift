//
//  PadelCourt.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

public struct PadelCourt {
    public let courtName: String
    public let id: String
    public let timeSlots: [TimeSlot]
    
    public init(courtName: String, id: String, timeSlotsArray: [TimeSlot]) {
        self.courtName = courtName
        self.id = id
        self.timeSlots = timeSlotsArray
    }
}
