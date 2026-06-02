//
//  TimeSlot.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

public struct TimeSlot {
    public let startingTime: String
    public let availability: Bool
    
    public init(startingTime: String, availability: Bool) {
        self.startingTime = startingTime
        self.availability = availability
    }
}
