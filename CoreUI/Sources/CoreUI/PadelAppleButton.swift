//
//  PadelAppleButton.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import AuthenticationServices
import DesignSystem
import SwiftUI

// MARK: - PadelAppleButton

/// Apple's own Sign in with Apple button, sized and clipped to match
/// `PadelButton`.
///
/// Apple requires their control rather than a redraw of it, so the only thing
/// this type does is give it the app's height and corner radius.
///
/// Two behaviours, because Sign in with Apple needs an entitlement the project
/// does not have yet and a server-side client id that is not configured:
/// `init(onRequest:onCompletion:)` is the real thing, and
/// `init(onUnavailableTap:)` renders the identical button but answers the tap
/// itself. Showing Apple's sheet only to have it fail is a worse answer than
/// saying plainly that the option is not ready.
public struct PadelAppleButton: View {

    private enum Behaviour {
        case live(
            onRequest: (ASAuthorizationAppleIDRequest) -> Void,
            onCompletion: (Result<ASAuthorization, Error>) -> Void
        )
        case unavailable(() -> Void)
    }

    private let behaviour: Behaviour

    public init(
        onRequest: @escaping (ASAuthorizationAppleIDRequest) -> Void,
        onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void
    ) {
        self.behaviour = .live(onRequest: onRequest, onCompletion: onCompletion)
    }

    public init(onUnavailableTap: @escaping () -> Void) {
        self.behaviour = .unavailable(onUnavailableTap)
    }

    public var body: some View {
        switch behaviour {
        case let .live(onRequest, onCompletion):
            appleButton(onRequest: onRequest, onCompletion: onCompletion)

        case let .unavailable(handler):
            appleButton(onRequest: { _ in }, onCompletion: { _ in })
                // Apple's control keeps its exact pixels; the tap is caught by
                // a transparent button laid over it.
                .allowsHitTesting(false)
                .overlay {
                    Button(action: handler) {
                        Color.clear.contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Continue with Apple")
                }
        }
    }

    private func appleButton(
        onRequest: @escaping (ASAuthorizationAppleIDRequest) -> Void,
        onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void
    ) -> some View {
        SignInWithAppleButton(.continue, onRequest: onRequest, onCompletion: onCompletion)
            .signInWithAppleButtonStyle(.black)
            .frame(height: PadelDesignTokens.Sizing.actionControl)
            .clipShape(
                RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xl, style: .continuous)
            )
    }
}

#Preview {
    VStack(spacing: PadelDesignTokens.Spacing.xl) {
        PadelAppleButton(onUnavailableTap: {})
        PadelAppleButton(onRequest: { _ in }, onCompletion: { _ in })
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
