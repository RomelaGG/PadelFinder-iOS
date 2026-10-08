//
//  DateFormatterProvider.swift
//  CoreFormatting
//
//  Created by Giorgi Romelashvili on 09.06.26.
//

import Foundation

final class DateFormatterProvider: DateFormatterProviderProtocol {

    // MARK: - ISO / Machine-Readable

    /// Formats and parses date-only strings in `yyyy-MM-dd` format.
    /// Use for API request/response date fields.
    /// - Note: Uses `en_US_POSIX` locale + Gregorian calendar per Apple's recommendation
    ///   for machine-readable date strings. Not suitable for display.
    let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Must match the calendar that produced the date. Callers pass calendar
        // days built with `Calendar.current.startOfDay`, so formatting them in
        // GMT shifted every one back a day: in Tbilisi (UTC+4) midnight local is
        // always the previous day in UTC, so the pill labelled Fri 9 Oct asked
        // the API for 2026-10-08.
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// Formats and parses full ISO 8601 datetime strings including timezone offset.
    /// Use for API timestamp fields (e.g. `2024-06-09T14:30:00.000Z`).
    let isoDateTimeFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()

    // MARK: - Display / Human-Readable

    /// Formats dates for UI display using the device's current locale.
    /// Example output: "Jun 9, 2024"
    /// - Warning: Do NOT use for API serialization — output varies by locale.
    let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    /// Formats dates as month + year for section headers and labels.
    /// Example output: "June 2024"
    /// - Warning: Do NOT use for API serialization — output varies by locale.
    let displayMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM yyyy",
            options: 0,
            locale: .current
        )
        return formatter
    }()
}
