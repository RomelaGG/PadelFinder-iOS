//
//  PadelDesignTokens.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI

public enum PadelDesignTokens {
    public enum Colors {
        public static let appBackground = Color(hex: 0xE5E5EA)
        public static let surface = Color(hex: 0xFFFFFF)
        public static let textPrimary = Color(hex: 0x111827)
        public static let textSecondary = Color(hex: 0x6B7280)
        public static let border = Color(hex: 0xD1D5DB)
        public static let courtGreen = Color(hex: 0x2F7D4F)
        public static let courtGreenPressed = Color(hex: 0x256540)
        public static let selectedText = Color(hex: 0xFFFFFF)
        public static let calendarCellShadow = Color(hex: 0x000000, opacity: 0.10)
        public static let slotBorder = Color(hex: 0xE5E7EB)
        public static let slotDisabledBackground = Color(hex: 0xF2F2F2)
        public static let slotDisabledBorder = Color(hex: 0xE5E5E5)
        public static let slotDisabledText = Color(hex: 0xA8A8A8)
    }

    public enum Fonts {
        public static let calendarWeekday = Font.system(size: 15, weight: .bold)
        public static let calendarDay = Font.system(size: 32, weight: .bold)
        public static let calendarMonth = Font.system(size: 14, weight: .bold)
        public static let availableSlot = Font.system(size: 18, weight: .bold)
    }

    public enum Spacing {
        public static let screenHorizontal: CGFloat = 16
        public static let calendarHorizontalInset: CGFloat = 12
        public static let calendarItem: CGFloat = 6
        public static let calendarCellHorizontal: CGFloat = 8
        public static let calendarCellVertical: CGFloat = 10
        public static let calendarCellContent: CGFloat = 2
        public static let calendarShadowVerticalInset: CGFloat = 6
        public static let availableSlotHorizontalInset: CGFloat = 12
        public static let availableSlotItem: CGFloat = 8
        public static let availableSlotShadowVerticalInset: CGFloat = 4
    }

    public enum Radius {
        public static let calendarCell: CGFloat = 22
        public static let availableSlot: CGFloat = 12
    }

    public enum Sizing {
        public static let calendarCellWidth: CGFloat = 60
        public static let calendarCellHeight: CGFloat = 92
        public static let calendarCellBorderWidth: CGFloat = 1
        public static let availableSlotWidth: CGFloat = 80
        public static let availableSlotHeight: CGFloat = 38
        public static let availableSlotBorderWidth: CGFloat = 1
    }

    public enum Shadow {
        public static let calendarCellRadius: CGFloat = 3
        public static let calendarCellX: CGFloat = 0
        public static let calendarCellY: CGFloat = 1
        public static let availableSlotRadius: CGFloat = 3
        public static let availableSlotX: CGFloat = 0
        public static let availableSlotY: CGFloat = 1
    }

    public enum CalendarLayout {
        public static let visibleDayCount = 21
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
