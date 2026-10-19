//
//  NewPasswordViewModel.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Combine
import CoreDI
import CoreUI
import DomainLayer
import SwiftUI

// MARK: - Field

enum NewPasswordField {
    case password
    case confirmation
}

// MARK: - Banner action

enum NewPasswordBannerAction: Equatable {
    /// The code turned out to be dead. Start the reset again rather than
    /// leaving the user on a form that can never succeed.
    case startOver

    /// The password was saved but the automatic sign-in did not go through.
    case signIn
}

// MARK: - State

struct NewPasswordViewModelState {
    let email: String
    let code: String

    var password = ""
    var confirmation = ""

    var passwordError: String?
    var confirmationError: String?
    var bannerMessage: String?
    var bannerKind: PadelInlineBanner.Kind = .error
    var bannerAction: NewPasswordBannerAction?

    var isSubmitting = false
    var hasFocusedPassword = false
    var focusRequest: NewPasswordField?
    var route: AuthRoute?

    var canSubmit: Bool {
        !password.isEmpty && !confirmation.isEmpty
    }
}

// MARK: - Intent

enum NewPasswordViewModelIntent {
    case passwordChanged(String)
    case confirmationChanged(String)
    case passwordFocused
    case confirmationBlurred
    case submitTapped
    case bannerActionTapped
    case focusHandled
    case routeHandled
}

// MARK: - ViewModel

/// The last step of a password reset.
///
/// This is also where a wrong reset code first surfaces: nothing validates the
/// code earlier, because `/auth/password/reset` is the endpoint that spends it.
/// So `invalid_code` and `code_burned` have to be handled here, not only on
/// the code screen.
@MainActor
final class NewPasswordViewModel: ObservableObject, FormBindable {
    @Published private(set) var state: NewPasswordViewModelState

    @Injected private var resetPasswordUseCase: any ResetPasswordUseCaseProtocol

    private var submitTask: Task<Void, Never>?
    private var submitGeneration = 0

    init(state: NewPasswordViewModelState) {
        self.state = state
    }

    deinit {
        submitTask?.cancel()
    }

    func handleIntent(_ intent: NewPasswordViewModelIntent) {
        switch intent {
        case let .passwordChanged(password):
            state.password = password
            state.passwordError = nil
            state.confirmationError = nil
            clearBanner()

        case let .confirmationChanged(confirmation):
            state.confirmation = confirmation
            state.confirmationError = nil

        case .passwordFocused:
            state.hasFocusedPassword = true

        case .confirmationBlurred:
            validateConfirmation()

        case .submitTapped:
            submit()

        case .bannerActionTapped:
            switch state.bannerAction {
            case .startOver:
                state.route = .replace(.forgotPassword(email: state.email))
            case .signIn:
                state.route = .replace(.signIn(email: state.email))
            case nil:
                break
            }

        case .focusHandled:
            state.focusRequest = nil

        case .routeHandled:
            state.route = nil
        }
    }
}

// MARK: - Private

private extension NewPasswordViewModel {

    func clearBanner() {
        state.bannerMessage = nil
        state.bannerAction = nil
    }

    func validateConfirmation() {
        guard !state.confirmation.isEmpty else { return }

        state.confirmationError = state.confirmation == state.password
            ? nil
            : AuthCopy.Error.passwordMismatch
    }

    func submit() {
        guard !state.isSubmitting else { return }

        clearBanner()
        state.hasFocusedPassword = true
        state.passwordError = PasswordPolicy.isValid(state.password)
            ? nil
            : AuthCopy.Error.weakPassword
        state.confirmationError = state.confirmation == state.password
            ? nil
            : AuthCopy.Error.passwordMismatch

        if state.passwordError != nil {
            state.focusRequest = .password
            return
        }

        if state.confirmationError != nil {
            state.focusRequest = .confirmation
            return
        }

        let password = state.password

        submitGeneration += 1
        let generation = submitGeneration

        submitTask?.cancel()
        submitTask = Task { [weak self] in
            await self?.performReset(password: password, generation: generation)
        }
    }

    func performReset(password: String, generation: Int) async {
        state.isSubmitting = true

        do {
            let user = try await resetPasswordUseCase.execute(
                email: state.email,
                code: state.code,
                newPassword: password
            )

            try Task.checkCancellation()
            guard generation == submitGeneration else { return }

            state.route = .replace(.success(email: user.email))
        } catch is CancellationError {
            return
        } catch {
            guard generation == submitGeneration, !Task.isCancelled else { return }

            handle(error)
        }

        state.isSubmitting = false
    }

    func handle(_ error: Error) {
        guard let domainError = error as? AuthDomainError else {
            state.bannerMessage = AuthCopy.Error.generic
            return
        }

        state.bannerKind = domainError.isRateLimit ? .warning : .error
        state.bannerMessage = domainError.localizedDescription

        switch domainError {
        case .invalidCode, .codeBurned:
            state.bannerAction = .startOver

        case .passwordSavedButSignInFailed:
            // The password really is saved. Sending the user back to a reset
            // form would make them change it again for no reason.
            state.bannerAction = .signIn

        default:
            break
        }
    }
}
