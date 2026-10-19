//
//  SignInViewModel.swift
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

enum SignInField {
    case email
    case password
}

// MARK: - Banner action

enum SignInBannerAction: Equatable {
    /// Offered when the account exists but its address was never confirmed.
    /// The server has already sent a fresh code by the time this appears.
    case sendCode
}

// MARK: - State

struct SignInViewModelState {
    var email = ""
    var password = ""

    var emailError: String?
    var passwordError: String?
    var bannerMessage: String?
    var bannerKind: PadelInlineBanner.Kind = .error
    var bannerAction: SignInBannerAction?

    var isSubmitting = false
    var focusRequest: SignInField?
    var route: AuthRoute?

    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty
    }
}

// MARK: - Intent

enum SignInViewModelIntent {
    case emailChanged(String)
    case passwordChanged(String)
    case emailBlurred
    case submitTapped
    case forgotPasswordTapped
    case createAccountTapped
    case bannerActionTapped
    case socialTapped(AuthProvider)
    case focusHandled
    case routeHandled
}

// MARK: - ViewModel

@MainActor
final class SignInViewModel: ObservableObject, FormBindable {
    @Published private(set) var state: SignInViewModelState

    @Injected private var signInUseCase: any SignInUseCaseProtocol

    private var submitTask: Task<Void, Never>?
    private var submitGeneration = 0

    init(state: SignInViewModelState) {
        self.state = state
    }

    deinit {
        submitTask?.cancel()
    }

    func handleIntent(_ intent: SignInViewModelIntent) {
        switch intent {
        case let .emailChanged(email):
            state.email = email
            state.emailError = nil
            clearBanner()

        case let .passwordChanged(password):
            state.password = password
            state.passwordError = nil

        case .emailBlurred:
            validateEmail()

        case .submitTapped:
            submit()

        case .forgotPasswordTapped:
            state.route = .push(.forgotPassword(email: state.email.isEmpty ? nil : state.email))

        case .createAccountTapped:
            state.route = .push(.signUp)

        case .bannerActionTapped:
            guard state.bannerAction == .sendCode else { return }

            state.route = .push(
                .verifyCode(
                    email: AuthValidation.normalizeEmail(state.email),
                    purpose: .verifyEmail
                )
            )

        case let .socialTapped(provider):
            show(AuthDomainError.socialSignInUnavailable(provider))

        case .focusHandled:
            state.focusRequest = nil

        case .routeHandled:
            state.route = nil
        }
    }
}

// MARK: - Private

private extension SignInViewModel {

    func clearBanner() {
        state.bannerMessage = nil
        state.bannerAction = nil
    }

    func validateEmail() {
        guard !state.email.isEmpty else { return }

        state.emailError = AuthValidation.isPlausibleEmail(state.email)
            ? nil
            : AuthCopy.Error.invalidEmail
    }

    func submit() {
        guard !state.isSubmitting else { return }

        clearBanner()

        // Only emptiness is checked on the password here. Telling somebody
        // their long-standing, working password is "weak" at the moment they
        // are trying to use it would be both wrong and insulting.
        state.emailError = state.email.isEmpty ? AuthCopy.Error.emptyEmail : nil
        state.passwordError = state.password.isEmpty ? AuthCopy.Error.emptyPassword : nil

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

        submitGeneration += 1
        let generation = submitGeneration

        submitTask?.cancel()
        submitTask = Task { [weak self] in
            await self?.performSignIn(email: email, password: password, generation: generation)
        }
    }

    func performSignIn(email: String, password: String, generation: Int) async {
        state.isSubmitting = true

        do {
            let user = try await signInUseCase.execute(email: email, password: password)

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

        switch domainError {
        case .invalidCredentials:
            // A banner, never a field error: saying which half was wrong tells
            // a stranger whether the address has an account.
            show(domainError)
            state.password = ""
            state.focusRequest = .password

        case .emailNotVerified:
            show(domainError)
            state.bannerAction = .sendCode

        default:
            show(domainError)
        }
    }

    func show(_ error: AuthDomainError) {
        state.bannerKind = error.isRateLimit ? .warning : .error
        state.bannerMessage = error.localizedDescription
    }
}
