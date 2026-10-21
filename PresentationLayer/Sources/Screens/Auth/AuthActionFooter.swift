//
//  AuthActionFooter.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 20.10.26.
//

import CoreUI
import DesignSystem
import SwiftUI

// MARK: - AuthActionFooter

/// The primary action, at the size the screen can afford.
///
/// Resting, it is a full-width button with the secondary prompt under it — the
/// shape a committing action deserves. Once the keyboard is up that costs about
/// 110pt of a form that is already short of room, so it collapses to a circular
/// arrow on the right and the prompt steps aside.
///
/// Reads `isKeyboardVisible` from the environment, which `AuthScreenScaffold`
/// publishes, rather than observing the keyboard itself.
struct AuthActionFooter<Prompt: View>: View {
    @Environment(\.isKeyboardVisible) private var isKeyboardVisible

    private let title: String
    private let isLoading: Bool
    private let isEnabled: Bool
    private let action: () -> Void
    private let prompt: Prompt

    init(
        title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder prompt: () -> Prompt
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
        self.prompt = prompt()
    }

    var body: some View {
        Group {
            if isKeyboardVisible {
                compact
            } else {
                full
            }
        }
        .animation(
            .easeOut(duration: PadelDesignTokens.Motion.standard),
            value: isKeyboardVisible
        )
    }
}

// MARK: - Shapes

private extension AuthActionFooter {

    var full: some View {
        VStack(spacing: PadelDesignTokens.Spacing.m) {
            PadelButton(title, isLoading: isLoading, isEnabled: isEnabled, action: action)

            prompt
        }
    }

    /// The prompt keeps its place on the left rather than disappearing: the row
    /// has the width going spare once the button is a circle, and losing the
    /// way to sign in the moment you start typing is a dead end.
    var compact: some View {
        HStack(alignment: .center, spacing: PadelDesignTokens.Spacing.xxxl) {
            prompt

            PadelIconButton(
                accessibilityLabel: title,
                isLoading: isLoading,
                isEnabled: isEnabled,
                action: action
            )
        }
    }
}
