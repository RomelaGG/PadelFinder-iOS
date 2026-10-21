//
//  PasswordRulesView.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PasswordPolicy

/// What counts as an acceptable new password: length, and nothing else.
///
/// Composition rules — a letter, a digit, a symbol — used to live here too.
/// They bought almost nothing (`12345678` simply becomes `1234567a`) while
/// pushing people towards predictable mutations, which is why NIST SP 800-63B
/// now says verifiers SHALL NOT impose them. Length is the floor that standard
/// does still require.
///
/// This matches the server exactly: `RegisterRequest` and `ResetPasswordRequest`
/// both validate `.count(8...256)` and apply no other rule. The one gap is the
/// upper bound, which is not mirrored here — a pasted passphrase over 256
/// characters passes this check and is refused by the backend.
public enum PasswordPolicy {

    public static let minimumLength = 8

    public enum Rule: CaseIterable {
        case length

        public var copy: String {
            switch self {
            case .length: return "At least \(PasswordPolicy.minimumLength) characters"
            }
        }

        func isMet(by password: String) -> Bool {
            switch self {
            case .length: return password.count >= PasswordPolicy.minimumLength
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
/// Shown only once the field has been focused — an unmet rule sitting under an
/// untouched form reads as a telling-off before the user has done anything.
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
