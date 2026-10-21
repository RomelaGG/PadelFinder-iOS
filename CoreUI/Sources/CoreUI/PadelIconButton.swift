//
//  PadelIconButton.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 20.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelIconButton

/// A circular action, for advancing through a flow rather than committing to
/// one. `PadelButton` is the commit; this is the "next".
///
/// Shares `PadelButton`'s height, fills and press behaviour so a column of one
/// and a row of the other read as the same family. It is a separate type rather
/// than a fifth `PadelButton.Style` because the difference is shape, not
/// colour: `PadelButtonStyle` hard-codes a rounded rectangle and a `stretches`
/// flag, and threading a shape through it would complicate four styles to serve
/// this one caller.
///
/// `accessibilityLabel` is required, not optional: an arrow announces nothing
/// on its own.
public struct PadelIconButton: View {
    private let systemImage: String
    private let accessibilityLabel: String
    private let isLoading: Bool
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        systemImage: String = "arrow.right",
        accessibilityLabel: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(PadelIconButtonStyle(isEnabled: isInteractive))
        .allowsHitTesting(isInteractive)
        .accessibilityLabel(isLoading ? "\(accessibilityLabel), loading" : accessibilityLabel)
    }

    /// Loading forces the control inert: a spinner that can still be tapped
    /// invites a second submit of whatever is already in flight.
    private var isInteractive: Bool { isEnabled && !isLoading }

    @ViewBuilder
    private var label: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(PadelDesignTokens.Colors.textDisabled)
        } else {
            Image(systemName: systemImage)
                .font(PadelDesignTokens.Fonts.symbol)
        }
    }
}

// MARK: - PadelIconButtonStyle

private struct PadelIconButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && isEnabled

        return configuration.label
            .foregroundStyle(labelColor(isPressed: isPressed))
            .frame(
                width: PadelDesignTokens.Sizing.actionControl,
                height: PadelDesignTokens.Sizing.actionControl
            )
            .background(fillColor(isPressed: isPressed))
            .clipShape(Circle())
            .scaleEffect(isPressed ? PadelDesignTokens.Motion.pressScale : 1)
            .animation(.easeOut(duration: PadelDesignTokens.Motion.fast), value: isPressed)
            .contentShape(Circle())
    }

    private func fillColor(isPressed: Bool) -> Color {
        guard isEnabled else { return PadelDesignTokens.Colors.surfaceMuted }

        return isPressed
            ? PadelDesignTokens.Colors.accentPressed
            : PadelDesignTokens.Colors.accent
    }

    private func labelColor(isPressed: Bool) -> Color {
        isEnabled
            ? PadelDesignTokens.Colors.onAccent
            : PadelDesignTokens.Colors.textDisabled
    }
}

#Preview {
    HStack(spacing: PadelDesignTokens.Spacing.xxxl) {
        PadelIconButton(accessibilityLabel: "Continue") {}
        PadelIconButton(accessibilityLabel: "Continue", isLoading: true) {}
        PadelIconButton(accessibilityLabel: "Continue", isEnabled: false) {}
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
