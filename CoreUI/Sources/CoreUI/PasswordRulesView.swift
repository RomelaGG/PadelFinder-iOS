//
//  PasswordRulesView.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PasswordPolicy

/// What counts as an acceptable new password.
///
/// Three rules, deliberately. Longer lists push people towards passwords they
/// have to write down, and the server only enforces length anyway — so this is
/// the stricter of the two and can never reject something the backend would
/// have accepted.
public enum PasswordPolicy {

    public static let minimumLength = 8

    public enum Rule: CaseIterable {
        case length
        case letter
        case number

        public var copy: String {
            switch self {
            case .length: return "At least \(PasswordPolicy.minimumLength) characters"
            case .letter: return "At least one letter"
            case .number: return "At least one number"
            }
        }

        func isMet(by password: String) -> Bool {
            switch self {
            case .length: return password.count >= PasswordPolicy.minimumLength
            case .letter: return password.contains(where: \.isLetter)
            case .number: return password.contains(where: \.isNumber)
            }
        }
    }

    public static func unmetRules(for password: String) -> [Rule] {
        Rule.allCases.filter { !$0.isMet(by: password) }
    }

    public static func isValid(_ password: String) -> Bool {
        unmetRules(for: password).isEmpty
    }
}

// MARK: - PasswordRulesView

/// The live checklist under a new-password field.
///
/// Shown only once the field has been focused — a checklist of three red
/// crosses on an untouched form reads as a telling-off before the user has
/// done anything.
public struct PasswordRulesView: View {
    private let password: String

    public init(password: String) {
        self.password = password
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.s) {
            ForEach(PasswordPolicy.Rule.allCases, id: \.self) { rule in
                row(for: rule, isMet: !PasswordPolicy.unmetRules(for: password).contains(rule))
            }
        }
        .animation(.easeOut(duration: PadelDesignTokens.Motion.fast), value: password)
        .accessibilityElement(children: .combine)
    }

    private func row(for rule: PasswordPolicy.Rule, isMet: Bool) -> some View {
        HStack(spacing: PadelDesignTokens.Spacing.m) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(
                    isMet
                        ? PadelDesignTokens.Colors.success
                        : PadelDesignTokens.Colors.textSecondary
                )

            Text(rule.copy)
                .font(PadelDesignTokens.Fonts.caption)
                .foregroundStyle(
                    isMet
                        ? PadelDesignTokens.Colors.textSupport
                        : PadelDesignTokens.Colors.textSecondary
                )
        }
        .accessibilityLabel("\(rule.copy), \(isMet ? "met" : "not met")")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xxxl) {
        PasswordRulesView(password: "")
        PasswordRulesView(password: "abcdefgh")
        PasswordRulesView(password: "abcdefg1")
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
