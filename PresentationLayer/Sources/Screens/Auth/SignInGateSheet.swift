//
//  SignInGateSheet.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreUI
import DesignSystem
import DomainLayer
import SwiftUI

/// A signed-out user tapped something that needs an account.
///
/// A half-sheet rather than the full flow, because the user was in the middle
/// of something and the point is to interrupt as little as possible. The
/// background is left alone on purpose: sheets are Liquid Glass for free on
/// iOS 26, and forcing an opaque `presentationBackground` throws that away for
/// nothing.
struct SignInGateSheet: View {
    @EnvironmentObject private var presenter: AuthPresenter

    @StateObject private var social = SocialSignInModel()

    private let reason: String?

    init(reason: String?) {
        self.reason = reason
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if let bannerMessage = social.bannerMessage {
                PadelInlineBanner(bannerMessage, kind: social.bannerKind)
                    .padding(.top, PadelDesignTokens.Layout.sectionGap)
            }

            methods
                .padding(.top, PadelDesignTokens.Layout.sectionGap)

            PadelButton(AuthCopy.Gate.notNow, style: .tertiary) {
                presenter.dismissGate()
            }
            .padding(.top, PadelDesignTokens.Spacing.xxxl)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, PadelDesignTokens.Layout.screenHorizontal)
        .padding(.top, PadelDesignTokens.Spacing.xxxl)
        .padding(.bottom, PadelDesignTokens.Layout.footerBottom)
        .frame(maxWidth: .infinity)
        .presentationDetents([.height(380)])
        .presentationDragIndicator(.visible)
        .modifier(SheetCornerRadius())
        .animation(
            .easeOut(duration: PadelDesignTokens.Motion.standard),
            value: social.bannerMessage
        )
        // Signed in, so the thing the user originally tapped is permitted now
        // and the interruption is over. `AuthRepository.adopt(_:)` has already
        // written the Keychain and flipped `AuthSession`, so there is nothing
        // left to do and nowhere to go - this sheet has no `Navigator` in its
        // environment, and a 380pt celebration over the thing the user was
        // actually doing would be the wrong answer even if it did.
        .onChange(of: social.signedInUser) { user in
            guard user != nil else { return }

            presenter.dismissGate()
        }
    }
}

// MARK: - Pieces

private extension SignInGateSheet {

    var header: some View {
        VStack(spacing: PadelDesignTokens.Spacing.m) {
            Text(AuthCopy.Gate.title)
                .font(PadelDesignTokens.Fonts.title)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)

            // `reason` lets the sheet be specific when that helps — "Sign in
            // to book Lemans Padel at 19:00." One line, or the default.
            Text(reason ?? AuthCopy.Gate.subtitle)
                .font(PadelDesignTokens.Fonts.body)
                .foregroundStyle(PadelDesignTokens.Colors.textSupport)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    var methods: some View {
        VStack(spacing: PadelDesignTokens.Layout.fieldGap) {
            SocialMethodButtons(social: social)

            // Hands off to the full flow through the presenter, which
            // dismisses this sheet first and presents the flow from
            // `onDismiss`. Presenting both in one frame drops the second.
            PadelButton(AuthCopy.Gate.email, style: .secondary) {
                presenter.continueWithEmailFromGate()
            }
        }
    }
}

// MARK: - SheetCornerRadius

/// `presentationCornerRadius` is iOS 16.4; the app ships to 16.0.
private struct SheetCornerRadius: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.presentationCornerRadius(PadelDesignTokens.Radius.xxxl)
        } else {
            content
        }
    }
}
