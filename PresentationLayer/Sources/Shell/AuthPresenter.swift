//
//  AuthPresenter.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Combine
import SwiftUI

// MARK: - Presentations

/// Where the user is going once they decide to sign in.
public enum AuthStart: String, Equatable, Sendable {
    case welcome
    case signIn
    case signUp
}

/// The half-sheet shown when a signed-out user taps something that needs an
/// account.
public struct AuthGatePresentation: Identifiable, Equatable, Sendable {
    public let id = "auth.gate"
    public let reason: String?
}

/// The full-screen flow.
public struct AuthFlowPresentation: Identifiable, Equatable, Sendable {
    public let start: AuthStart
    public let raisedByGate: Bool

    public var id: String { "auth.flow.\(start.rawValue)" }
}

// MARK: - AuthPresenter

/// Decides who shows auth, and how.
///
/// Both modals hang off the tab shell rather than off individual screens, so
/// there is exactly one place either can be presented from and no two screens
/// can race to present the same thing.
@MainActor
public final class AuthPresenter: ObservableObject {

    @Published public private(set) var gate: AuthGatePresentation?
    @Published public private(set) var flow: AuthFlowPresentation?

    /// Set when the gate hands off to the full flow. iOS will not reliably
    /// swap one modal for another in the same frame, so the gate is dismissed
    /// first and this is picked up from the sheet's `onDismiss`.
    private var pendingFlow: AuthFlowPresentation?

    public nonisolated init() { }

    // MARK: Presenting

    public func presentGate(reason: String? = nil) {
        flow = nil
        gate = AuthGatePresentation(reason: reason)
    }

    public func presentFlow(_ start: AuthStart = .welcome) {
        gate = nil
        flow = AuthFlowPresentation(start: start, raisedByGate: false)
    }

    /// "Continue with email", tapped inside the gate sheet.
    public func continueWithEmailFromGate() {
        pendingFlow = AuthFlowPresentation(start: .welcome, raisedByGate: true)
        gate = nil
    }

    /// Called from the gate sheet's `onDismiss`. The naive version - setting
    /// `flow` at the moment the button is tapped - drops the second modal.
    public func presentPendingFlowIfNeeded() {
        guard let pendingFlow else { return }

        self.pendingFlow = nil
        flow = pendingFlow
    }

    // MARK: Dismissing

    public func dismissGate() {
        gate = nil
    }

    public func dismissFlow() {
        flow = nil
    }

    public func dismiss() {
        pendingFlow = nil
        gate = nil
        flow = nil
    }

    // MARK: Bindings

    public var gateBinding: Binding<AuthGatePresentation?> {
        Binding(
            get: { self.gate },
            set: { if $0 == nil { self.dismissGate() } }
        )
    }

    public var flowBinding: Binding<AuthFlowPresentation?> {
        Binding(
            get: { self.flow },
            set: { if $0 == nil { self.dismissFlow() } }
        )
    }
}
