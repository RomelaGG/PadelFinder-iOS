//
//  PadelStateView.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelStateView

/// The three things a screen shows when it has no content: loading, nothing,
/// or a failure worth retrying.
///
/// One component rather than a hand-rolled `if` ladder per screen, so a new
/// screen cannot invent a fourth visual language for "empty".
public struct PadelStateView: View {

    public enum Kind {
        case loading
        case empty(icon: String, title: String, message: String?)
        case error(message: String, retry: () -> Void)
    }

    private let kind: Kind
    private let minHeight: CGFloat

    public init(_ kind: Kind, minHeight: CGFloat = 180) {
        self.kind = kind
        self.minHeight = minHeight
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity)
            .frame(minHeight: minHeight)
    }

    @ViewBuilder
    private var content: some View {
        switch kind {
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(PadelDesignTokens.Colors.accent)

        case let .empty(icon, title, message):
            messageBlock(icon: icon, title: title, message: message, action: nil)

        case let .error(message, retry):
            messageBlock(
                icon: "exclamationmark.triangle",
                title: "Something went wrong",
                message: message,
                action: retry
            )
        }
    }

    @ViewBuilder
    private func messageBlock(
        icon: String,
        title: String,
        message: String?,
        action: (() -> Void)?
    ) -> some View {
        VStack(spacing: PadelDesignTokens.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                .accessibilityHidden(true)

            Text(title)
                .font(PadelDesignTokens.Fonts.bodyStrong)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)

            if let message {
                Text(message)
                    .font(PadelDesignTokens.Fonts.body)
                    .foregroundStyle(PadelDesignTokens.Colors.textSupport)
                    .multilineTextAlignment(.center)
            }

            if let action {
                PadelButton("Try again", style: .tertiary, action: action)
            }
        }
        .padding(.horizontal, PadelDesignTokens.Layout.screenHorizontal)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: PadelDesignTokens.Spacing.xxxl) {
            PadelStateView(.loading)

            PadelStateView(
                .empty(
                    icon: "calendar.badge.plus",
                    title: "No bookings yet",
                    message: "Sign in to book a court and see it here."
                )
            )

            PadelStateView(.error(message: "No internet connection.", retry: {}))
        }
        .padding()
    }
    .background(PadelDesignTokens.Colors.background)
}
