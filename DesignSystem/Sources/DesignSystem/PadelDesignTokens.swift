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

        /// The readable grey. Field labels, helper text, subtitles, legal copy — anything
        /// under 18pt that carries meaning. 5.65:1 on `background`.
        ///
        /// `textSecondary` measures only 2.91:1 there, below the 4.5:1 AA floor, so it is
        /// reserved for text at 18pt bold or larger.
        public static let textSupport = Color(hex: 0x5F5F66)

        public static let error = Color(hex: 0xC2301C)
        public static let errorSurface = Color(hex: 0xFDECEA)
        public static let errorBorder = Color(hex: 0xEFC7C0)
        public static let success = Color(hex: 0x137A4D)
        public static let successSurface = Color(hex: 0xE8F3ED)
        public static let warning = Color(hex: 0xB45309)
        public static let warningSurface = Color(hex: 0xFDF4E3)
        public static let accentSurface = Color(hex: 0xE8F3ED)
        public static let accentBorder = Color(hex: 0xBFDFD0)
        public static let overlay = Color(hex: 0x000000, opacity: 0.40)
        public static let focusRing = Color(hex: 0x137A4D, opacity: 0.25)
        public static let skeleton = Color(hex: 0xEAEAE8)
        public static let appleButton = Color(hex: 0x000000)
    }

    public enum Fonts {
        public static let captionStrong = Font.system(size: 14, weight: .bold)
        public static let footnoteStrong = Font.system(size: 15, weight: .bold)
        public static let body = Font.system(size: 15, weight: .regular)
        public static let bodyStrong = Font.system(size: 18, weight: .bold)
        public static let input = Font.system(size: 20, weight: .regular)
        public static let title = Font.system(size: 22, weight: .bold)
        public static let largeTitle = Font.system(size: 26, weight: .bold)
        public static let symbol = Font.system(size: 22, weight: .semibold)

        /// Auth screen title.
        public static let display = Font.system(size: 32, weight: .bold)
        /// Auth screen subtitle, list row title.
        public static let subheadline = Font.system(size: 16, weight: .regular)
        /// Every button label.
        public static let callout = Font.system(size: 16, weight: .semibold)
        /// Field label above an input.
        public static let label = Font.system(size: 14, weight: .semibold)
        /// Helper text, legal microcopy, password rules.
        public static let caption = Font.system(size: 13, weight: .regular)
        /// Inline text links.
        public static let link = Font.system(size: 15, weight: .semibold)
        /// OTP cell. Monospaced so digits do not jitter as they land.
        public static let otpDigit = Font.system(size: 28, weight: .semibold).monospacedDigit()
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

        public static let otpCellWidth: CGFloat = 48
        public static let otpCellHeight: CGFloat = 60
        public static let avatarSmall: CGFloat = 38
        public static let avatarLarge: CGFloat = 88
        public static let tabBarIcon: CGFloat = 24
        public static let checkbox: CGFloat = 22
        public static let listRow: CGFloat = 56
        public static let brandMark: CGFloat = 72
        public static let bannerMinHeight: CGFloat = 48
    }

    /// Page structure. `Spacing` is tuned for the inside of a card; these are the
    /// rhythms between blocks on a screen.
    public enum Layout {
        public static let screenHorizontal: CGFloat = 16
        public static let fieldGap: CGFloat = 12
        public static let sectionGap: CGFloat = 24
        public static let blockGap: CGFloat = 32
        public static let heroTop: CGFloat = 40
        public static let footerBottom: CGFloat = 24
        /// What `footerBottom` shrinks to while the keyboard is up: the home
        /// indicator it clears is gone, and the form needs the height more.
        public static let footerBottomCompact: CGFloat = 8
        /// Auth content is centred and capped on iPad.
        public static let maxContentWidth: CGFloat = 420
    }

    public enum Motion {
        /// Focus ring, button press, checkbox tick.
        public static let fast: Double = 0.18
        /// Error text, step transitions, banner in/out.
        public static let standard: Double = 0.28
        /// Scale applied while a button is held.
        public static let pressScale: CGFloat = 0.97
        /// OTP wrong-code shake: 3 oscillations, ±8pt.
        public static let shakeDuration: Double = 0.4
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

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255

        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
