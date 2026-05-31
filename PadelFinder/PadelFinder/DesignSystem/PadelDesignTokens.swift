//
//  PadelDesignTokens.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI

enum PadelDesignTokens {
    enum Colors {
        static let appBackground = Color(hex: 0xE5E5EA)
        static let surface = Color(hex: 0xFFFFFF)
        static let textPrimary = Color(hex: 0x111827)
        static let textSecondary = Color(hex: 0x6B7280)
        static let border = Color(hex: 0xD1D5DB)
        static let courtGreen = Color(hex: 0x2F7D4F)
        static let courtGreenPressed = Color(hex: 0x256540)
        static let selectedText = Color(hex: 0xFFFFFF)
        static let calendarCellShadow = Color(hex: 0x000000, opacity: 0.10)
    }

    enum Fonts {
        static let calendarWeekday = Font.system(size: 15, weight: .bold)
        static let calendarDay = Font.system(size: 32, weight: .bold)
        static let calendarMonth = Font.system(size: 14, weight: .bold)
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 16
        static let calendarItem: CGFloat = 12
        static let calendarCellHorizontal: CGFloat = 8
        static let calendarCellVertical: CGFloat = 10
        static let calendarCellContent: CGFloat = 2
        static let calendarShadowVerticalInset: CGFloat = 6
    }

    enum Radius {
        static let calendarCell: CGFloat = 22
    }

    enum Sizing {
        static let calendarCellWidth: CGFloat = 72
        static let calendarCellHeight: CGFloat = 112
        static let calendarCellBorderWidth: CGFloat = 1
    }

    enum Shadow {
        static let calendarCellRadius: CGFloat = 3
        static let calendarCellX: CGFloat = 0
        static let calendarCellY: CGFloat = 1
    }

    enum CalendarLayout {
        static let visibleDayCount = 21
    }
}

private extension Color {
    init(hex: UInt, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255

        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
