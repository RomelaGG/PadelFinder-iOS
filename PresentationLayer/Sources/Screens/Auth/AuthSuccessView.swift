//
//  AuthSuccessView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI
import UIKit

/// Confirms, then gets out of the way.
///
/// No button: it dismisses itself after 1.2 seconds. A "Done" button here
/// would be a tap that only means "yes, I read the thing you just told me".
struct AuthSuccessView: View {
    @EnvironmentObject private var presenter: AuthPresenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var hasAppeared = false

    private let email: String?

    init(email: String?) {
        self.email = email
    }

    var body: some View {
        VStack(spacing: PadelDesignTokens.Layout.sectionGap) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: PadelDesignTokens.Sizing.avatarLarge, weight: .regular))
                .foregroundStyle(PadelDesignTokens.Colors.accent)
                .scaleEffect(scale)
                .opacity(hasAppeared ? 1 : 0)
                .accessibilityHidden(true)

            VStack(spacing: PadelDesignTokens.Spacing.m) {
                Text(AuthCopy.Success.title)
                    .font(PadelDesignTokens.Fonts.display)
                    .foregroundStyle(PadelDesignTokens.Colors.textPrimary)

                Text(subtitle)
                    .font(PadelDesignTokens.Fonts.subheadline)
                    .foregroundStyle(PadelDesignTokens.Colors.textSupport)
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, PadelDesignTokens.Layout.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PadelDesignTokens.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: appear)
        .accessibilityElement(children: .combine)
    }

    private var subtitle: String {
        guard let email, !email.isEmpty else { return AuthCopy.Success.subtitleFallback }

        return AuthCopy.Success.subtitle(email)
    }

    private var scale: CGFloat {
        hasAppeared ? 1 : 0.6
    }

    private func appear() {
        guard !hasAppeared else { return }

        // Reduce Motion gets the cross-fade the opacity change already
        // provides, without the spring.
        if reduceMotion {
            hasAppeared = true
        } else {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.65)) {
                hasAppeared = true
            }
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            presenter.dismissFlow()
        }
    }
}
