//
//  PadelBrandMark.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelBrandMark

/// A padel court on a tinted green tile — the app's mark on the Welcome screen
/// and in the Account promo card.
///
/// The court lines are the same drawing `InitialsBadge` puts behind a club's
/// initials, which is what makes the two read as the same product rather than
/// two apps that happen to share a colour.
public struct PadelBrandMark: View {
    private let size: CGFloat

    public init(size: CGFloat = PadelDesignTokens.Sizing.brandMark) {
        self.size = size
    }

    public var body: some View {
        courtLines
            .padding(size * 0.22)
            .frame(width: size, height: size)
            .background(PadelDesignTokens.Colors.accentSurface)
            .clipShape(
                RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xxl, style: .continuous)
            )
            .accessibilityHidden(true)
    }

    private var courtLines: some View {
        GeometryReader { proxy in
            let size = proxy.size

            Path { path in
                path.addRect(CGRect(origin: .zero, size: size))
                path.move(to: CGPoint(x: size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: size.width / 2, y: size.height))
                path.move(to: CGPoint(x: 0, y: size.height / 2))
                path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
            }
            .stroke(PadelDesignTokens.Colors.accent, lineWidth: 1.5)
        }
    }
}

#Preview {
    HStack(spacing: PadelDesignTokens.Spacing.xxxl) {
        PadelBrandMark()
        PadelBrandMark(size: 44)
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
