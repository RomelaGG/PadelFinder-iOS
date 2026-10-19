//
//  ForgotPasswordViewModel.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Combine
import CoreDI
import CoreUI
import DomainLayer
import SwiftUI

// MARK: - State

struct ForgotPasswordViewModelState {
    var email = ""

    var emailError: String?
    var bannerMessage: String?
    var bannerKind: PadelInlineBanner.Kind = .error

    var isSubmitting = false
    var focusRequest: Bool = false
    var route: AuthRoute?

    var canSubmit: Bool { !email.isEmpty }
}

// MARK: - Intent

enum ForgotPasswordViewModelIntent {
    case emailChanged(String)
    case emailBlurred
    case submitTapped
    case focusHandled
    case routeHandled
}

// MARK: - ViewModel

@MainActor
final class ForgotPasswordViewModel: ObservableObject, FormBindable {
    @Published private(set) var state: ForgotPasswordViewModelState

    @Injected private var requestPasswordResetUseCase: any RequestPasswordResetUseCaseProtocol

    private var submitTask: Task<Void, Never>?
    private var submitGeneration = 0

    init(state: ForgotPasswordViewModelState) {
        self.state = state
    }

    deinit {
        submitTask?.cancel()
    }

    func handleIntent(_ intent: ForgotPasswordViewModelIntent) {
        switch intent {
        case let .emailChanged(email):
            state.email = email
            state.emailError = nil
            state.bannerMessage = nil

        case .emailBlurred:
            guard !state.email.isEmpty else { return }

            state.emailError = AuthValidation.isPlausibleEmail(state.email)
                ? nil
                : AuthCopy.Error.invalidEmail

        case .submitTapped:
            submit()

        case .focusHandled:
            state.focusRequest = false

        case .routeHandled:
            state.route = nil
        }
    }
}

// MARK: - Private

private extension ForgotPasswordViewModel {

    func submit() {
        guard !state.isSubmitting else { return }

        state.bannerMessage = nil
        state.emailError = state.email.isEmpty
            ? AuthCopy.Error.emptyEmail
            : (AuthValidation.isPlausibleEmail(state.email) ? nil : AuthCopy.Error.invalidEmail)

        if state.emailError != nil {
            state.focusRequest = true
            return
        }

        let email = AuthValidation.normalizeEmail(state.email)

        submitGeneration += 1
        let generation = submitGeneration

        submitTask?.cancel()
        submitTask = Task { [weak self] in
            await self?.performRequest(email: email, generation: generation)
        }
    }

    func performRequest(email: String, generation: Int) async {
        state.isSubmitting = true

        do {
            try await requestPasswordResetUseCase.execute(email: email)

            try Task.checkCancellation()
            guard generation == submitGeneration else { return }

            // Advances whether or not the address has an account. The server
            // answers the same way either way, and branching here would turn
            // this screen into a way to check who is registered.
            state.route = .push(.verifyCode(email: email, purpose: .resetPassword))
        } catch is CancellationError {
            return
        } catch {
            guard generation == submitGeneration, !Task.isCancelled else { return }

            let domainError = error as? AuthDomainError

            state.bannerKind = domainError.map { $0.isRateLimit ? .warning : .error } ?? .error
            state.bannerMessage = domainError?.localizedDescription ?? AuthCopy.Error.generic
        }

        state.isSubmitting = false
    }
}
