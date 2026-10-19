//
//  PadelButton.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelButton

/// Every button in the app that is not Apple's own.
///
/// One height (`Sizing.actionControl`) and one label font (`Fonts.callout`) for
/// all four styles, so a column of buttons lines up without anyone measuring.
public struct PadelButton: View {

    public enum Style {
        case primary
        case secondary
        case tertiary
        case destructive
    }

    private let title: String
    private let style: Style
    private let icon: Image?
    private let isLoading: Bool
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        style: Style = .primary,
        icon: Image? = nil,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(
            PadelButtonStyle(
                style: style,
                isEnabled: isInteractive,
                stretches: style.stretches
            )
        )
        .allowsHitTesting(isInteractive)
        .accessibilityLabel(isLoading ? "\(title), loading" : title)
    }

    /// Loading forces the button inert: a spinner that can still be tapped
    /// invites a second submit of whatever is already in flight.
    private var isInteractive: Bool { isEnabled && !isLoading }

    @ViewBuilder
    private var label: some View {
        if isLoading {
            // Sized by an invisible copy of the real label so the control keeps
            // its width — a button that shrinks when tapped reads as a glitch.
            ProgressView()
                .progressViewStyle(.circular)
                .tint(style.labelColor(isEnabled: false, isPressed: false))
                .frame(maxWidth: style.stretches ? .infinity : nil)
                .overlay {
                    titleRow.hidden()
                }
        } else {
            titleRow
        }
    }

    private var titleRow: some View {
        HStack(spacing: PadelDesignTokens.Spacing.m) {
            if let icon {
                icon
                    .font(PadelDesignTokens.Fonts.callout)
                    .accessibilityHidden(true)
            }

            Text(title)
                .font(PadelDesignTokens.Fonts.callout)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
    }
}

// MARK: - PadelButtonStyle

private struct PadelButtonStyle: ButtonStyle {
    let style: PadelButton.Style
    let isEnabled: Bool
    let stretches: Bool

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && isEnabled

        return configuration.label
            .foregroundStyle(style.labelColor(isEnabled: isEnabled, isPressed: isPressed))
            .frame(maxWidth: stretches ? .infinity : nil)
            .frame(height: PadelDesignTokens.Sizing.actionControl)
            .padding(.horizontal, stretches ? 0 : PadelDesignTokens.Spacing.xxxl)
            .background(style.fillColor(isEnabled: isEnabled, isPressed: isPressed))
            .clipShape(shape)
            .overlay {
                if let border = style.borderColor(isEnabled: isEnabled) {
                    shape.stroke(border, lineWidth: PadelDesignTokens.Sizing.hairline)
                }
            }
            .scaleEffect(isPressed && style.scalesWhenPressed ? PadelDesignTokens.Motion.pressScale : 1)
            .animation(.easeOut(duration: PadelDesignTokens.Motion.fast), value: isPressed)
            .contentShape(shape)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xl, style: .continuous)
    }
}

// MARK: - Style tables

private extension PadelButton.Style {

    /// `.tertiary` and `.destructive` are the only styles allowed to be
    /// narrower than the column they sit in — they read as links, not actions.
    var stretches: Bool {
        switch self {
        case .primary, .secondary:   return true
        case .tertiary, .destructive: return false
        }
    }

    var scalesWhenPressed: Bool {
        switch self {
        case .primary, .secondary:    return true
        case .tertiary, .destructive: return false
        }
    }

    func fillColor(isEnabled: Bool, isPressed: Bool) -> Color {
        guard isEnabled else {
            switch self {
            case .primary, .secondary:    return PadelDesignTokens.Colors.surfaceMuted
            case .tertiary, .destructive: return .clear
            }
        }

        switch self {
        case .primary:
            return isPressed
                ? PadelDesignTokens.Colors.accentPressed
                : PadelDesignTokens.Colors.accent

        case .secondary:
            // `accentBorder` is the darkened step of `accentSurface` and is
            // already a token, so the pressed fill needs no new colour.
            return isPressed
                ? PadelDesignTokens.Colors.accentBorder
                : PadelDesignTokens.Colors.accentSurface

        case .tertiary, .destructive:
            return .clear
        }
    }

    func labelColor(isEnabled: Bool, isPressed: Bool) -> Color {
        guard isEnabled else {
            return PadelDesignTokens.Colors.textDisabled
        }

        switch self {
        case .primary:
            return PadelDesignTokens.Colors.onAccent

        case .secondary, .tertiary:
            return isPressed
                ? PadelDesignTokens.Colors.accentPressed
                : PadelDesignTokens.Colors.accent

        case .destructive:
            return PadelDesignTokens.Colors.error.opacity(isPressed ? 0.7 : 1)
        }
    }

    func borderColor(isEnabled: Bool) -> Color? {
        switch self {
        case .secondary where isEnabled: return PadelDesignTokens.Colors.accentBorder
        default:                         return nil
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: PadelDesignTokens.Spacing.xl) {
            PadelButton("Create account") {}
            PadelButton("Create account", isLoading: true) {}
            PadelButton("Create account", isEnabled: false) {}

            PadelButton("Sign up with email", style: .secondary) {}
            PadelButton("Sign up with email", style: .secondary, isLoading: true) {}

            PadelButton("Forgot password?", style: .tertiary) {}
            PadelButton("Delete account", style: .destructive) {}

            PadelButton("Continue", icon: Image(systemName: "arrow.right")) {}
        }
        .padding()
    }
    .background(PadelDesignTokens.Colors.background)
}
