//
//  DateFormatterProviderProtocol.swift
//  CoreFormatting
//
//  Created by Giorgi Romelashvili on 09.06.26.
//

import Foundation

public protocol DateFormatterProviderProtocol {
    var isoDateFormatter: DateFormatter { get }
    var isoDateTimeFormatter: ISO8601DateFormatter { get }
    var displayDateFormatter: DateFormatter { get }
    var displayMonthYearFormatter: DateFormatter { get }
}
