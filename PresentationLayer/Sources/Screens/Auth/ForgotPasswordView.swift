//
//  ForgotPasswordView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import CoreUI
import DesignSystem
import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel: ForgotPasswordViewModel
    @EnvironmentObject private var navigator: Navigator<AuthNavigatorDestination>

    @FocusState private var isEmailFocused: Bool

    init(viewModel: ForgotPasswordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AuthScreenScaffold(
            title: AuthCopy.Forgot.title,
            subtitle: AuthCopy.Forgot.subtitle
        ) {
            form
        } footer: {
            PadelButton(
                AuthCopy.Forgot.submit,
                isLoading: viewModel.state.isSubmitting,
                isEnabled: viewModel.state.canSubmit
            ) {
                viewModel.handleIntent(.submitTapped)
            }
        }
        .navBarButton(.back) { navigator.pop() }
        .onAppear { isEmailFocused = true }
        .onChange(of: isEmailFocused) { isFocused in
            if !isFocused { viewModel.handleIntent(.emailBlurred) }
        }
        .onChange(of: viewModel.state.focusRequest) { shouldFocus in
            guard shouldFocus else { return }

            isEmailFocused = true
            viewModel.handleIntent(.focusHandled)
        }
        .authRouting(viewModel.state.route) {
            viewModel.handleIntent(.routeHandled)
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Layout.fieldGap) {
            if let message = viewModel.state.bannerMessage {
                PadelInlineBanner(message, kind: viewModel.state.bannerKind)
                    .padding(.bottom, PadelDesignTokens.Spacing.xs)
            }

            PadelTextField(
                AuthCopy.Field.email,
                text: viewModel.binding(\.email, ForgotPasswordViewModelIntent.emailChanged),
                kind: .email,
                errorText: viewModel.state.emailError,
                isEnabled: !viewModel.state.isSubmitting,
                submitLabel: .go,
                isFocused: $isEmailFocused,
                onSubmit: { viewModel.handleIntent(.submitTapped) }
            )
        }
        .animation(
            .easeOut(duration: PadelDesignTokens.Motion.standard),
            value: viewModel.state.bannerMessage
        )
    }
}
