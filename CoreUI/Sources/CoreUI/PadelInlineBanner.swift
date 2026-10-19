//
//  PadelInlineBanner.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI
import UIKit

// MARK: - PadelInlineBanner

/// The place a screen says what went wrong, when the message belongs to the
/// whole form rather than to one field.
///
/// Announces itself to VoiceOver on appear. Doing that here rather than at
/// every call site is what makes the accessibility rule hold by construction:
/// a banner nobody remembered to announce is silent, and an error nobody hears
/// is an error nobody can fix.
public struct PadelInlineBanner: View {

    public enum Kind {
        case error
        case success
        case info
        case warning
    }

    private let message: String
    private let kind: Kind
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        _ message: String,
        kind: Kind = .error,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.kind = kind
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .top, spacing: PadelDesignTokens.Spacing.l) {
            Image(systemName: kind.iconName)
                .font(PadelDesignTokens.Fonts.bodyStrong)
                .foregroundStyle(kind.accentColor)
                .accessibilityHidden(true)

            Text(message)
                .font(PadelDesignTokens.Fonts.body)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(PadelDesignTokens.Fonts.link)
                        .foregroundStyle(kind.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(PadelDesignTokens.Spacing.xl)
        .frame(minHeight: PadelDesignTokens.Sizing.bannerMinHeight)
        .background(kind.fillColor)
        .clipShape(shape)
        .overlay {
            if let border = kind.borderColor {
                shape.stroke(border, lineWidth: PadelDesignTokens.Sizing.hairline)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
        .onAppear { announce() }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.l, style: .continuous)
    }

    private func announce() {
        guard UIAccessibility.isVoiceOverRunning else { return }

        // One hop, so the announcement does not race the banner's own
        // insertion into the accessibility tree and get dropped.
        Task { @MainActor in
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
}

// MARK: - Kind table

private extension PadelInlineBanner.Kind {

    var iconName: String {
        switch self {
        case .error:   return "exclamationmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "clock.fill"
        case .info:    return "info.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .error:   return PadelDesignTokens.Colors.error
        case .success: return PadelDesignTokens.Colors.success
        case .warning: return PadelDesignTokens.Colors.warning
        case .info:    return PadelDesignTokens.Colors.textSupport
        }
    }

    var fillColor: Color {
        switch self {
        case .error:   return PadelDesignTokens.Colors.errorSurface
        case .success: return PadelDesignTokens.Colors.successSurface
        case .warning: return PadelDesignTokens.Colors.warningSurface
        case .info:    return PadelDesignTokens.Colors.surfaceMuted
        }
    }

    var borderColor: Color? {
        switch self {
        case .error:   return PadelDesignTokens.Colors.errorBorder
        case .success: return PadelDesignTokens.Colors.accentBorder
        case .warning: return nil
        case .info:    return PadelDesignTokens.Colors.border
        }
    }
}

#Preview {
    VStack(spacing: PadelDesignTokens.Spacing.xl) {
        PadelInlineBanner("That email or password is not right.")

        PadelInlineBanner(
            "Confirm your email to continue.",
            actionTitle: "Send code",
            action: {}
        )

        PadelInlineBanner("New code sent.", kind: .success)

        PadelInlineBanner(
            "Too many codes requested for this address. Try again later.",
            kind: .warning
        )

        PadelInlineBanner("We sent a 6-digit code to you@example.com.", kind: .info)
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
