//
//  SignInView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import CoreUI
import DesignSystem
import DomainLayer
import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel: SignInViewModel
    @EnvironmentObject private var navigator: Navigator<AuthNavigatorDestination>

    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    init(viewModel: SignInViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AuthScreenScaffold(
            title: AuthCopy.SignIn.title,
            subtitle: AuthCopy.SignIn.subtitle
        ) {
            form
        } footer: {
            footer
        }
        .navBarButton(.back) { navigator.pop() }
        .onChange(of: isEmailFocused) { isFocused in
            if !isFocused { viewModel.handleIntent(.emailBlurred) }
        }
        .onChange(of: viewModel.state.focusRequest) { request in
            applyFocus(request)
        }
        .authRouting(viewModel.state.route) {
            viewModel.handleIntent(.routeHandled)
        }
    }
}

// MARK: - Pieces

private extension SignInView {

    var form: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Layout.fieldGap) {
            if let message = viewModel.state.bannerMessage {
                PadelInlineBanner(
                    message,
                    kind: viewModel.state.bannerKind,
                    actionTitle: viewModel.state.bannerAction == .sendCode
                        ? AuthCopy.SignIn.sendCode
                        : nil
                ) {
                    viewModel.handleIntent(.bannerActionTapped)
                }
                .padding(.bottom, PadelDesignTokens.Spacing.xs)
            }

            PadelTextField(
                AuthCopy.Field.email,
                text: viewModel.binding(\.email, SignInViewModelIntent.emailChanged),
                kind: .email,
                errorText: viewModel.state.emailError,
                isEnabled: !viewModel.state.isSubmitting,
                submitLabel: .next,
                isFocused: $isEmailFocused,
                onSubmit: { isPasswordFocused = true }
            )

            PadelTextField(
                AuthCopy.Field.password,
                text: viewModel.binding(\.password, SignInViewModelIntent.passwordChanged),
                kind: .password,
                errorText: viewModel.state.passwordError,
                isEnabled: !viewModel.state.isSubmitting,
                submitLabel: .go,
                isFocused: $isPasswordFocused,
                onSubmit: { viewModel.handleIntent(.submitTapped) }
            )

            HStack {
                Spacer(minLength: 0)

                PadelButton(AuthCopy.SignIn.forgot, style: .tertiary) {
                    viewModel.handleIntent(.forgotPasswordTapped)
                }
            }

            PadelLabeledDivider(AuthCopy.Common.or)
                .padding(.vertical, PadelDesignTokens.Spacing.xl)

            PadelAppleButton {
                viewModel.handleIntent(.socialTapped(.apple))
            }

            PadelSocialButton(provider: .google) {
                viewModel.handleIntent(.socialTapped(.google))
            }
        }
        .animation(
            .easeOut(duration: PadelDesignTokens.Motion.standard),
            value: viewModel.state.bannerMessage
        )
    }

    var footer: some View {
        VStack(spacing: PadelDesignTokens.Spacing.m) {
            PadelButton(
                AuthCopy.SignIn.submit,
                isLoading: viewModel.state.isSubmitting,
                isEnabled: viewModel.state.canSubmit
            ) {
                viewModel.handleIntent(.submitTapped)
            }

            AuthFooterPrompt(
                question: AuthCopy.SignIn.newHere,
                actionTitle: AuthCopy.Common.createAccount
            ) {
                viewModel.handleIntent(.createAccountTapped)
            }
        }
    }

    func applyFocus(_ request: SignInField?) {
        guard let request else { return }

        switch request {
        case .email:    isEmailFocused = true
        case .password: isPasswordFocused = true
        }

        viewModel.handleIntent(.focusHandled)
    }
}
