//
//  DateAvailableCompanies.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

public struct DateCheckAvailability: Sendable {
    public let date: String
    
    public init(date: String) {
        self.date = date
    }
}
