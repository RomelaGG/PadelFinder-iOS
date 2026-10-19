//
//  PadelLabeledDivider.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelLabeledDivider

/// "——— or ———": the seam between signing in with a provider and signing in
/// with an email.
///
/// Hidden from VoiceOver — the grouping is visual, and read aloud it is just
/// the word "or" between two buttons that already explain themselves.
public struct PadelLabeledDivider: View {
    private let label: String

    public init(_ label: String = "or") {
        self.label = label
    }

    public var body: some View {
        HStack(spacing: PadelDesignTokens.Spacing.xl) {
            line

            Text(label)
                .font(PadelDesignTokens.Fonts.caption)
                .foregroundStyle(PadelDesignTokens.Colors.textSupport)

            line
        }
        .accessibilityHidden(true)
    }

    private var line: some View {
        Rectangle()
            .fill(PadelDesignTokens.Colors.border)
            .frame(height: PadelDesignTokens.Sizing.hairline)
    }
}

#Preview {
    VStack(spacing: PadelDesignTokens.Spacing.xxxl) {
        PadelLabeledDivider()
        PadelLabeledDivider("or continue with")
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
