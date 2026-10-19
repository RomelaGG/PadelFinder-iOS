//
//  SignUpViewModel.swift
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

enum SignUpField {
    case nickname
    case email
    case password
}

// MARK: - State

struct SignUpViewModelState {
    var nickname = ""
    var email = ""
    var password = ""
    var acceptedTerms = false

    var emailError: String?
    var passwordError: String?
    var bannerMessage: String?
    var bannerKind: PadelInlineBanner.Kind = .error

    var isSubmitting = false

    /// The password checklist appears only once the field has been touched. A
    /// list of unticked rules on an untouched form reads as a telling-off.
    var hasFocusedPassword = false

    var focusRequest: SignUpField?
    var route: AuthRoute?

    /// Enabled whenever there is something to submit, not only when every
    /// rule passes. A disabled button that will not say why is the most
    /// frustrating thing a mobile form can do - better to let the tap happen
    /// and answer with a real error.
    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && acceptedTerms
    }
}

// MARK: - Intent

enum SignUpViewModelIntent {
    case nicknameChanged(String)
    case emailChanged(String)
    case passwordChanged(String)
    case termsToggled(Bool)
    case emailBlurred
    case passwordFocused
    case submitTapped
    case signInTapped
    case focusHandled
    case routeHandled
}

// MARK: - ViewModel

@MainActor
final class SignUpViewModel: ObservableObject, FormBindable {
    @Published private(set) var state: SignUpViewModelState

    @Injected private var registerUseCase: any RegisterUseCaseProtocol

    private var submitTask: Task<Void, Never>?
    private var submitGeneration = 0

    init(state: SignUpViewModelState) {
        self.state = state
    }

    deinit {
        submitTask?.cancel()
    }

    func handleIntent(_ intent: SignUpViewModelIntent) {
        switch intent {
        case let .nicknameChanged(nickname):
            state.nickname = nickname

        case let .emailChanged(email):
            state.email = email
            // Typing only ever clears an error. Showing a new one mid-word
            // tells somebody their half-typed address is wrong.
            state.emailError = nil
            state.bannerMessage = nil

        case let .passwordChanged(password):
            state.password = password
            state.passwordError = nil

        case let .termsToggled(accepted):
            state.acceptedTerms = accepted

        case .emailBlurred:
            validateEmail()

        case .passwordFocused:
            state.hasFocusedPassword = true

        case .submitTapped:
            submit()

        case .signInTapped:
            state.route = .push(.signIn(email: state.email.isEmpty ? nil : state.email))

        case .focusHandled:
            state.focusRequest = nil

        case .routeHandled:
            state.route = nil
        }
    }
}

// MARK: - Private

private extension SignUpViewModel {

    func validateEmail() {
        guard !state.email.isEmpty else { return }

        state.emailError = AuthValidation.isPlausibleEmail(state.email)
            ? nil
            : AuthCopy.Error.invalidEmail
    }

    func submit() {
        guard !state.isSubmitting else { return }

        state.bannerMessage = nil
        state.emailError = state.email.isEmpty
            ? AuthCopy.Error.emptyEmail
            : (AuthValidation.isPlausibleEmail(state.email) ? nil : AuthCopy.Error.invalidEmail)
        state.passwordError = PasswordPolicy.isValid(state.password)
            ? nil
            : AuthCopy.Error.weakPassword
        state.hasFocusedPassword = true

        // The first failing field takes focus, so fixing it is one tap away
        // rather than a hunt up the form.
        if state.emailError != nil {
            state.focusRequest = .email
            return
        }

        if state.passwordError != nil {
            state.focusRequest = .password
            return
        }

        let email = AuthValidation.normalizeEmail(state.email)
        let password = state.password
        let nickname = AuthValidation.normalizeNickname(state.nickname)

        submitGeneration += 1
        let generation = submitGeneration

        submitTask?.cancel()
        submitTask = Task { [weak self] in
            await self?.performRegister(
                email: email,
                password: password,
                nickname: nickname,
                generation: generation
            )
        }
    }

    func performRegister(
        email: String,
        password: String,
        nickname: String?,
        generation: Int
    ) async {
        state.isSubmitting = true

        do {
            try await registerUseCase.execute(
                email: email,
                password: password,
                displayName: nickname
            )

            try Task.checkCancellation()
            guard generation == submitGeneration else { return }

            // Always forward on success, and success is all this endpoint
            // ever reports: it answers 202 even for an address that already
            // has an account, so that it cannot be used to find out who is
            // registered. The code screen carries the way out for somebody
            // who picked the wrong button.
            state.route = .push(.verifyCode(email: email, purpose: .verifyEmail))
        } catch is CancellationError {
            return
        } catch {
            guard generation == submitGeneration, !Task.isCancelled else { return }

            show(error)
        }

        state.isSubmitting = false
    }

    func show(_ error: Error) {
        let domainError = error as? AuthDomainError

        state.bannerKind = domainError.map { $0.isRateLimit ? .warning : .error } ?? .error
        state.bannerMessage = domainError?.localizedDescription
            ?? AuthCopy.Error.generic
    }
}

// MARK: - Rate limiting

extension AuthDomainError {
    /// Rate limits get the warning treatment: nothing is broken, the user
    /// just has to wait.
    var isRateLimit: Bool {
        if case .tooManyRequests = self { return true }

        return false
    }
}
