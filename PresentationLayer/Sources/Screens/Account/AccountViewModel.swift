//
//  AccountViewModel.swift
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

struct AccountViewModelState {
    var isSigningOut = false
    var isDeleting = false

    var bannerMessage: String?

    var isSignOutDialogPresented = false
    var isDeleteAlertPresented = false

    var isBusy: Bool { isSigningOut || isDeleting }
}

// MARK: - Intent

enum AccountViewModelIntent {
    case signInTapped
    case signOutTapped
    case signOutConfirmed
    case deleteAccountTapped
    case deleteAccountConfirmed
    case dialogDismissed
    case alertDismissed
}

// MARK: - ViewModel

@MainActor
final class AccountViewModel: ObservableObject {
    @Published private(set) var state: AccountViewModelState

    @Injected private var signOutUseCase: any SignOutUseCaseProtocol
    @Injected private var deleteAccountUseCase: any DeleteAccountUseCaseProtocol

    private var task: Task<Void, Never>?

    init(state: AccountViewModelState) {
        self.state = state
    }

    deinit {
        task?.cancel()
    }

    func handleIntent(_ intent: AccountViewModelIntent) {
        switch intent {
        case .signInTapped:
            break

        case .signOutTapped:
            state.isSignOutDialogPresented = true

        case .signOutConfirmed:
            signOut()

        case .deleteAccountTapped:
            state.isDeleteAlertPresented = true

        case .deleteAccountConfirmed:
            deleteAccount()

        case .dialogDismissed:
            state.isSignOutDialogPresented = false

        case .alertDismissed:
            state.isDeleteAlertPresented = false
        }
    }
}

// MARK: - Private

private extension AccountViewModel {

    func signOut() {
        guard !state.isBusy else { return }

        task?.cancel()
        task = Task { [weak self] in
            await self?.performSignOut()
        }
    }

    func performSignOut() async {
        state.isSigningOut = true
        state.bannerMessage = nil

        // Cannot fail: the server call is a courtesy, and the device ends up
        // signed out either way. `AuthSession` flips underneath us, which is
        // what swaps this screen back to the promo card.
        await signOutUseCase.execute()

        state.isSigningOut = false
    }

    func deleteAccount() {
        guard !state.isBusy else { return }

        task?.cancel()
        task = Task { [weak self] in
            await self?.performDelete()
        }
    }

    func performDelete() async {
        state.isDeleting = true
        state.bannerMessage = nil

        do {
            try await deleteAccountUseCase.execute()
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }

            state.bannerMessage = (error as? AuthDomainError)?.localizedDescription
                ?? AuthCopy.Error.generic
        }

        state.isDeleting = false
    }
}
