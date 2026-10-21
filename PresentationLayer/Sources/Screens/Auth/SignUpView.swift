//
//  SignUpView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import CoreUI
import DesignSystem
import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel: SignUpViewModel
    @EnvironmentObject private var navigator: Navigator<AuthNavigatorDestination>

    @FocusState private var isNicknameFocused: Bool
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    init(viewModel: SignUpViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AuthScreenScaffold(
            title: AuthCopy.SignUp.title,
            subtitle: AuthCopy.SignUp.subtitle
        ) {
            form
        } footer: {
            footer
        }
        .navBarButton(.back) { navigator.pop() }
        .onChange(of: isEmailFocused) { isFocused in
            if !isFocused { viewModel.handleIntent(.emailBlurred) }
        }
        .onChange(of: isPasswordFocused) { isFocused in
            if isFocused { viewModel.handleIntent(.passwordFocused) }
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

private extension SignUpView {

    var form: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Layout.fieldGap) {
            if let message = viewModel.state.bannerMessage {
                PadelInlineBanner(message, kind: viewModel.state.bannerKind)
                    .padding(.bottom, PadelDesignTokens.Spacing.xs)
            }

            PadelTextField(
                AuthCopy.Field.nickname,
                text: viewModel.binding(\.nickname, SignUpViewModelIntent.nicknameChanged),
                kind: .name,
                helperText: AuthCopy.Field.nicknameHelper,
                isEnabled: !viewModel.state.isSubmitting,
                submitLabel: .next,
                isFocused: $isNicknameFocused,
                onSubmit: { isEmailFocused = true }
            )

            PadelTextField(
                AuthCopy.Field.email,
                text: viewModel.binding(\.email, SignUpViewModelIntent.emailChanged),
                kind: .email,
                errorText: viewModel.state.emailError,
                isEnabled: !viewModel.state.isSubmitting,
                submitLabel: .next,
                isFocused: $isEmailFocused,
                onSubmit: { isPasswordFocused = true }
            )

            PadelTextField(
                AuthCopy.Field.password,
                text: viewModel.binding(\.password, SignUpViewModelIntent.passwordChanged),
                kind: .newPassword,
                errorText: viewModel.state.passwordError,
                isEnabled: !viewModel.state.isSubmitting,
                submitLabel: .done,
                isFocused: $isPasswordFocused,
                onSubmit: { viewModel.handleIntent(.submitTapped) }
            )

            if viewModel.state.hasFocusedPassword {
                PasswordRulesView(password: viewModel.state.password)
                    .padding(.top, PadelDesignTokens.Spacing.xs)
            }

            PadelCheckbox(
                isOn: viewModel.binding(\.acceptedTerms, SignUpViewModelIntent.termsToggled)
            ) {
                AuthLegalText(prefix: AuthCopy.SignUp.termsPrefix, alignment: .leading)
            }
            .padding(.top, PadelDesignTokens.Spacing.xl)
            .allowsHitTesting(!viewModel.state.isSubmitting)
        }
        .animation(
            .easeOut(duration: PadelDesignTokens.Motion.standard),
            value: viewModel.state.bannerMessage
        )
    }

    var footer: some View {
        AuthActionFooter(
            title: AuthCopy.SignUp.submit,
            isLoading: viewModel.state.isSubmitting,
            isEnabled: viewModel.state.canSubmit
        ) {
            viewModel.handleIntent(.submitTapped)
        } prompt: {
            AuthFooterPrompt(
                question: AuthCopy.Welcome.haveAccount,
                actionTitle: AuthCopy.Common.signIn
            ) {
                viewModel.handleIntent(.signInTapped)
            }
        }
    }

    func applyFocus(_ request: SignUpField?) {
        guard let request else { return }

        switch request {
        case .nickname: isNicknameFocused = true
        case .email:    isEmailFocused = true
        case .password: isPasswordFocused = true
        }

        viewModel.handleIntent(.focusHandled)
    }
}
