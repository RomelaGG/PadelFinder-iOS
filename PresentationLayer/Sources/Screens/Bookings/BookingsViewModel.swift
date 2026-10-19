//
//  BookingsViewModel.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Combine
import SwiftUI

// MARK: - State

struct BookingsViewModelState { }

// MARK: - Intent

enum BookingsViewModelIntent {
    case signInTapped
}

// MARK: - ViewModel

/// A placeholder, and honestly so: the backend has no booking endpoints at
/// all. The tab exists now because the sign-in surface needs a findable home
/// and bookings need somewhere to land when they arrive.
@MainActor
final class BookingsViewModel: ObservableObject {
    @Published private(set) var state: BookingsViewModelState

    init(state: BookingsViewModelState) {
        self.state = state
    }

    func handleIntent(_ intent: BookingsViewModelIntent) {
        switch intent {
        case .signInTapped:
            break
        }
    }
}
