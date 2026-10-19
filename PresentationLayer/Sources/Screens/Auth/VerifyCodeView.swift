//
//  VerifyCodeView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import CoreUI
import DesignSystem
import SwiftUI
import UIKit

/// One screen, two jobs: confirming a new email address, and entering a
/// password-reset code.
///
/// There is deliberately no Verify button — the sixth digit submits. A button
/// after a filled code field is a tap that carries no information.
struct VerifyCodeView: View {
    @StateObject private var viewModel: VerifyCodeViewModel
    @EnvironmentObject private var navigator: Navigator<AuthNavigatorDestination>

    @FocusState private var isCodeFocused: Bool

    init(viewModel: VerifyCodeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AuthScreenScaffold(
            title: viewModel.state.title,
            subtitle: viewModel.state.subtitle
        ) {
            content
        } footer: {
            footer
        }
        .navBarButton(.back) { navigator.pop() }
        .onAppear(perform: appear)
        .authRouting(viewModel.state.route) {
            viewModel.handleIntent(.routeHandled)
        }
    }
}

// MARK: - Pieces

private extension VerifyCodeView {

    var content: some View {
        VStack(spacing: PadelDesignTokens.Layout.sectionGap) {
            if let message = viewModel.state.bannerMessage {
                PadelInlineBanner(message, kind: viewModel.state.bannerKind)
            }

            PadelOTPField(
                code: viewModel.binding(\.code, VerifyCodeViewModelIntent.codeChanged),
                hasError: viewModel.state.hasError,
                isEnabled: viewModel.state.isCodeEntryEnabled && !viewModel.state.isSubmitting,
                isFocused: $isCodeFocused
            ) { code in
                viewModel.handleIntent(.codeCompleted(code))
            }
            .frame(maxWidth: .infinity, alignment: .center)

            if viewModel.state.isSubmitting {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(PadelDesignTokens.Colors.accent)
            } else {
                ResendTimerButton(secondsRemaining: viewModel.state.secondsRemaining) {
                    viewModel.handleIntent(.resendTapped)
                }
            }

            PadelButton(AuthCopy.OTP.changeEmail, style: .tertiary) {
                viewModel.handleIntent(.changeEmailTapped)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, PadelDesignTokens.Layout.sectionGap)
        .animation(
            .easeOut(duration: PadelDesignTokens.Motion.standard),
            value: viewModel.state.bannerMessage
        )
    }

    /// The way out for somebody who tapped "Sign up" when they already have an
    /// account. The server answers sign-up with 202 and sends nothing in that
    /// case - by design, so that nobody can test which addresses are
    /// registered - which would otherwise leave them waiting here for a code
    /// that is never coming.
    @ViewBuilder
    var footer: some View {
        if viewModel.state.purpose == .verifyEmail {
            AuthFooterPrompt(
                question: AuthCopy.OTP.haveAccount,
                actionTitle: AuthCopy.Common.signIn
            ) {
                viewModel.handleIntent(.signInTapped)
            }
        } else {
            EmptyView()
        }
    }

    func appear() {
        viewModel.handleIntent(.appeared)
        isCodeFocused = true

        // So a VoiceOver user hears which address the code went to without
        // having to go looking for the subtitle.
        if UIAccessibility.isVoiceOverRunning {
            Task { @MainActor in
                UIAccessibility.post(notification: .announcement, argument: viewModel.state.subtitle)
            }
        }
    }
}
