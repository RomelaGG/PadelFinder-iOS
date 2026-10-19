//
//  NewPasswordView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreUI
import DesignSystem
import SwiftUI

/// No back button, and nothing behind it: this screen is reached by replacing
/// the stack, because the code that got here has been spent and going back
/// would land on a dead one.
struct NewPasswordView: View {
    @StateObject private var viewModel: NewPasswordViewModel

    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isConfirmationFocused: Bool

    init(viewModel: NewPasswordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AuthScreenScaffold(
            title: AuthCopy.NewPassword.title,
            subtitle: AuthCopy.NewPassword.subtitle
        ) {
            form
        } footer: {
            PadelButton(
                AuthCopy.NewPassword.submit,
                isLoading: viewModel.state.isSubmitting,
                isEnabled: viewModel.state.canSubmit
            ) {
                viewModel.handleIntent(.submitTapped)
            }
        }
        // Reached by replacing the stack, so the native back item would pop to
        // Welcome. Hiding the bar takes the item and its swipe gesture with it.
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { isPasswordFocused = true }
        .onChange(of: isPasswordFocused) { isFocused in
            if isFocused { viewModel.handleIntent(.passwordFocused) }
        }
        .onChange(of: isConfirmationFocused) { isFocused in
            if !isFocused { viewModel.handleIntent(.confirmationBlurred) }
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

private extension NewPasswordView {

    var form: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Layout.fieldGap) {
            if let message = viewModel.state.bannerMessage {
                PadelInlineBanner(
                    message,
                    kind: viewModel.state.bannerKind,
                    actionTitle: bannerActionTitle
                ) {
                    viewModel.handleIntent(.bannerActionTapped)
                }
                .padding(.bottom, PadelDesignTokens.Spacing.xs)
            }

            PadelTextField(
                AuthCopy.Field.newPassword,
                text: viewModel.binding(\.password, NewPasswordViewModelIntent.passwordChanged),
                kind: .newPassword,
                errorText: viewModel.state.passwordError,
                isEnabled: !viewModel.state.isSubmitting,
                submitLabel: .next,
                isFocused: $isPasswordFocused,
                onSubmit: { isConfirmationFocused = true }
            )

            PadelTextField(
                AuthCopy.Field.confirmPassword,
                text: viewModel.binding(
                    \.confirmation,
                    NewPasswordViewModelIntent.confirmationChanged
                ),
                kind: .newPassword,
                errorText: viewModel.state.confirmationError,
                isEnabled: !viewModel.state.isSubmitting,
                submitLabel: .go,
                isFocused: $isConfirmationFocused,
                onSubmit: { viewModel.handleIntent(.submitTapped) }
            )

            if viewModel.state.hasFocusedPassword {
                PasswordRulesView(password: viewModel.state.password)
                    .padding(.top, PadelDesignTokens.Spacing.xs)
            }
        }
        .padding(.bottom, PadelDesignTokens.Layout.sectionGap)
        .animation(
            .easeOut(duration: PadelDesignTokens.Motion.standard),
            value: viewModel.state.bannerMessage
        )
    }

    var bannerActionTitle: String? {
        switch viewModel.state.bannerAction {
        case .startOver: return AuthCopy.NewPassword.startOver
        case .signIn:    return AuthCopy.Common.signIn
        case nil:        return nil
        }
    }

    func applyFocus(_ request: NewPasswordField?) {
        guard let request else { return }

        switch request {
        case .password:     isPasswordFocused = true
        case .confirmation: isConfirmationFocused = true
        }

        viewModel.handleIntent(.focusHandled)
    }
}
