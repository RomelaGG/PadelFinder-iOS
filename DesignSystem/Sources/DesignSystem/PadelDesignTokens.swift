//
//  PadelDesignTokens.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI

public enum PadelDesignTokens {
    public enum Colors {
        public static let background = Color(hex: 0xF2F2F0)
        public static let surface = Color(hex: 0xFFFFFF)
        public static let surfaceMuted = Color(hex: 0xF2F2F2)
        public static let textPrimary = Color(hex: 0x0A0A0A)
        public static let textSecondary = Color(hex: 0x8E8E93)
        public static let textDisabled = Color(hex: 0xB8B5AF)
        public static let border = Color(hex: 0xE5E5E5)
        public static let borderStrong = Color(hex: 0xD1D5DB)
        public static let accent = Color(hex: 0x137A4D)
        public static let accentPressed = Color(hex: 0x0E5F3B)
        public static let onAccent = Color(hex: 0xFFFFFF)
        public static let shadowLow = Color(hex: 0x000000, opacity: 0.10)
        public static let shadowRaised = Color(hex: 0x000000, opacity: 0.08)
    }

    public enum Fonts {
        public static let captionStrong = Font.system(size: 14, weight: .bold)
        public static let footnoteStrong = Font.system(size: 15, weight: .bold)
        public static let body = Font.system(size: 17, weight: .regular)
        public static let bodyStrong = Font.system(size: 18, weight: .bold)
        public static let input = Font.system(size: 20, weight: .regular)
        public static let title = Font.system(size: 22, weight: .bold)
        public static let largeTitle = Font.system(size: 26, weight: .bold)
        public static let symbol = Font.system(size: 22, weight: .semibold)
    }

    public enum Spacing {
        public static let xxs: CGFloat = 2
        public static let xs: CGFloat = 4
        public static let s: CGFloat = 6
        public static let m: CGFloat = 8
        public static let l: CGFloat = 10
        public static let xl: CGFloat = 12
        public static let xxl: CGFloat = 14
        public static let xxxl: CGFloat = 16
        public static let xxxxl: CGFloat = 18
    }

    public enum Radius {
        public static let s: CGFloat = 6
        public static let m: CGFloat = 8
        public static let l: CGFloat = 12
        public static let xl: CGFloat = 18
        public static let xxl: CGFloat = 22
        public static let xxxl: CGFloat = 28
    }

    public enum Sizing {
        public static let hairline: CGFloat = 1
        public static let compactControlHeight: CGFloat = 38
        public static let actionControl: CGFloat = 56
        public static let compactTileWidth: CGFloat = 60
        public static let mediaThumbnail: CGFloat = 76
        public static let regularTileWidth: CGFloat = 80
        public static let tallTileHeight: CGFloat = 92
    }

    public enum Shadow {
        public static let lowRadius: CGFloat = 3
        public static let lowX: CGFloat = 0
        public static let lowY: CGFloat = 1
        public static let raisedRadius: CGFloat = 8
        public static let raisedX: CGFloat = 0
        public static let raisedY: CGFloat = 2
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
