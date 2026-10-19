//
//  PadelLoadingOverlay.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - padelLoadingOverlay

public extension View {
    /// Freezes the whole screen behind a scrim and a spinner card.
    ///
    /// Only for work that owns the screen — completing a provider sign-in,
    /// where the provider's own sheet has been covering everything and a
    /// button spinner would never have been visible. Ordinary form submission
    /// uses `PadelButton(isLoading:)`; stacking both says the same thing twice.
    func padelLoadingOverlay(_ isLoading: Bool, message: String? = nil) -> some View {
        overlay {
            if isLoading {
                PadelLoadingOverlayContent(message: message)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: PadelDesignTokens.Motion.standard), value: isLoading)
    }
}

// MARK: - PadelLoadingOverlayContent

private struct PadelLoadingOverlayContent: View {
    let message: String?

    var body: some View {
        ZStack {
            PadelDesignTokens.Colors.overlay
                .ignoresSafeArea()

            VStack(spacing: PadelDesignTokens.Spacing.xxxl) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(PadelDesignTokens.Colors.accent)

                if let message {
                    Text(message)
                        .font(PadelDesignTokens.Fonts.body)
                        .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(PadelDesignTokens.Spacing.xxxxl)
            .frame(minWidth: PadelDesignTokens.Sizing.brandMark)
            .background(PadelDesignTokens.Colors.surface)
            .clipShape(
                RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xxl, style: .continuous)
            )
            .shadow(
                color: PadelDesignTokens.Colors.shadowRaised,
                radius: PadelDesignTokens.Shadow.raisedRadius,
                x: PadelDesignTokens.Shadow.raisedX,
                y: PadelDesignTokens.Shadow.raisedY
            )
        }
        .allowsHitTesting(true)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    VStack(spacing: PadelDesignTokens.Spacing.xl) {
        PadelButton("Continue with Apple") {}
        PadelButton("Continue with Google", style: .secondary) {}
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(PadelDesignTokens.Colors.background)
    .padelLoadingOverlay(true, message: "Signing you in…")
}
