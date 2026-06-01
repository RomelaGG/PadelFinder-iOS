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
        static let slotBorder = Color(hex: 0xE5E7EB)
        static let slotDisabledBackground = Color(hex: 0xF2F2F2)
        static let slotDisabledBorder = Color(hex: 0xE5E5E5)
        static let slotDisabledText = Color(hex: 0xA8A8A8)
    }

    enum Fonts {
        static let calendarWeekday = Font.system(size: 15, weight: .bold)
        static let calendarDay = Font.system(size: 32, weight: .bold)
        static let calendarMonth = Font.system(size: 14, weight: .bold)
        static let availableSlot = Font.system(size: 18, weight: .bold)
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 16
        static let calendarHorizontalInset: CGFloat = 12
        static let calendarItem: CGFloat = 6
        static let calendarCellHorizontal: CGFloat = 8
        static let calendarCellVertical: CGFloat = 10
        static let calendarCellContent: CGFloat = 2
        static let calendarShadowVerticalInset: CGFloat = 6
        static let availableSlotHorizontalInset: CGFloat = 12
        static let availableSlotItem: CGFloat = 8
        static let availableSlotShadowVerticalInset: CGFloat = 4
    }

    enum Radius {
        static let calendarCell: CGFloat = 22
        static let availableSlot: CGFloat = 12
    }

    enum Sizing {
        static let calendarCellWidth: CGFloat = 60
        static let calendarCellHeight: CGFloat = 92
        static let calendarCellBorderWidth: CGFloat = 1
        static let availableSlotWidth: CGFloat = 80
        static let availableSlotHeight: CGFloat = 38
        static let availableSlotBorderWidth: CGFloat = 1
    }

    enum Shadow {
        static let calendarCellRadius: CGFloat = 3
        static let calendarCellX: CGFloat = 0
        static let calendarCellY: CGFloat = 1
        static let availableSlotRadius: CGFloat = 3
        static let availableSlotX: CGFloat = 0
        static let availableSlotY: CGFloat = 1
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
