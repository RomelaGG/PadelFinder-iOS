//
//  TimeSlot.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

public enum TimeSlotStatus: String, Equatable, Sendable {
    case available
    case booked
    case maintenance
}

public struct TimeSlot: Equatable, Sendable {
    public let startingTime: String
    public let status: TimeSlotStatus
    public let isBookable: Bool
    
    public var availability: Bool {
        isBookable
    }

    public init(
        startingTime: String,
        status: TimeSlotStatus,
        isBookable: Bool
    ) {
        self.startingTime = startingTime
        self.status = status
        self.isBookable = isBookable
    }
}
