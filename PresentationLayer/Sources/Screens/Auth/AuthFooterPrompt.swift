//
//  AuthFooterPrompt.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - AuthFooterPrompt

/// "Already have an account?  Sign in" — the way between sign-up and sign-in.
///
/// The whole row is a 44pt target rather than just the green words, which are
/// about 60pt wide and otherwise easy to miss.
struct AuthFooterPrompt: View {
    private let question: String
    private let actionTitle: String
    private let action: () -> Void

    init(question: String, actionTitle: String, action: @escaping () -> Void) {
        self.question = question
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: PadelDesignTokens.Spacing.s) {
                Text(question)
                    .font(PadelDesignTokens.Fonts.body)
                    .foregroundStyle(PadelDesignTokens.Colors.textSupport)

                Text(actionTitle)
                    .font(PadelDesignTokens.Fonts.link)
                    .foregroundStyle(PadelDesignTokens.Colors.accent)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(question) \(actionTitle)")
    }
}

#Preview {
    AuthFooterPrompt(
        question: AuthCopy.Welcome.haveAccount,
        actionTitle: AuthCopy.Common.signIn,
        action: {}
    )
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
