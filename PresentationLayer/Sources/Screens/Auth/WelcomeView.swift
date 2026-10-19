//
//  WelcomeView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import CoreUI
import DesignSystem
import DomainLayer
import SwiftUI

/// The root of the auth flow: pick a method.
///
/// Sign in and sign up are separate buttons rather than one "Continue" that
/// looks the email up first. A lookup would answer whether an address has an
/// account, which is the one thing the backend works hard not to reveal.
struct WelcomeView: View {
    @EnvironmentObject private var navigator: Navigator<AuthNavigatorDestination>
    @EnvironmentObject private var presenter: AuthPresenter

    @State private var bannerMessage: String?

    var body: some View {
        AuthScreenScaffold {
            content
        } footer: {
            AuthFooterPrompt(
                question: AuthCopy.Welcome.haveAccount,
                actionTitle: AuthCopy.Common.signIn
            ) {
                navigator.push(.signIn(email: nil))
            }
        }
        .navBarButton(.close) { presenter.dismissFlow() }
    }
}

// MARK: - Pieces

private extension WelcomeView {

    var content: some View {
        VStack(spacing: 0) {
            PadelBrandMark()
                .padding(.top, PadelDesignTokens.Layout.heroTop)

            heroText
                .padding(.top, PadelDesignTokens.Layout.sectionGap)

            if let bannerMessage {
                PadelInlineBanner(bannerMessage)
                    .padding(.top, PadelDesignTokens.Layout.sectionGap)
            }

            methods
                .padding(.top, PadelDesignTokens.Layout.blockGap)

            AuthLegalText(prefix: AuthCopy.Welcome.legalPrefix)
                .padding(.top, PadelDesignTokens.Layout.sectionGap)
                .padding(.bottom, PadelDesignTokens.Layout.sectionGap)
        }
        .frame(maxWidth: .infinity)
        .animation(
            .easeOut(duration: PadelDesignTokens.Motion.standard),
            value: bannerMessage
        )
    }

    var heroText: some View {
        VStack(spacing: PadelDesignTokens.Spacing.m) {
            Text(AuthCopy.Welcome.title)
                .font(PadelDesignTokens.Fonts.display)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(AuthCopy.Welcome.subtitle)
                .font(PadelDesignTokens.Fonts.subheadline)
                .foregroundStyle(PadelDesignTokens.Colors.textSupport)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    var methods: some View {
        VStack(spacing: PadelDesignTokens.Layout.fieldGap) {
            PadelAppleButton {
                show(AuthDomainError.socialSignInUnavailable(.apple))
            }

            PadelSocialButton(provider: .google) {
                show(AuthDomainError.socialSignInUnavailable(.google))
            }

            PadelLabeledDivider(AuthCopy.Common.or)
                .padding(.vertical, PadelDesignTokens.Spacing.xl)

            PadelButton(AuthCopy.Welcome.email, style: .secondary) {
                navigator.push(.signUp)
            }
        }
    }

    /// `ASAuthorizationError.canceled` would be silent here if Apple were
    /// wired — a user who backed out of the sheet does not need an error.
    func show(_ error: AuthDomainError) {
        bannerMessage = error.localizedDescription
    }
}
