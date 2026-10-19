//
//  AuthLegalText.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import DomainLayer
import SwiftUI

// MARK: - AuthLegalText

/// "… our Terms of Service and Privacy Policy." with the two names in accent.
///
/// Not tappable while `LegalLinks` is empty — the pages do not exist yet, and a
/// link that opens nothing is worse than a name that was never a link. Fill in
/// `LegalLinks` and this becomes live with no change here.
struct AuthLegalText: View {
    private let prefix: String
    private let alignment: TextAlignment

    init(prefix: String, alignment: TextAlignment = .center) {
        self.prefix = prefix
        self.alignment = alignment
    }

    var body: some View {
        text
            .font(PadelDesignTokens.Fonts.caption)
            .foregroundColor(PadelDesignTokens.Colors.textSupport)
            .multilineTextAlignment(alignment)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var text: Text {
        Text(prefix)
            + accented(AuthCopy.Common.terms)
            + Text(" and ")
            + accented(AuthCopy.Common.privacy)
            + Text(trailingPeriod)
    }

    private func accented(_ value: String) -> Text {
        Text(value).foregroundColor(PadelDesignTokens.Colors.accent)
    }

    /// The checkbox label is a clause, the Welcome blurb is a sentence.
    private var trailingPeriod: String {
        prefix.hasPrefix("By continuing") ? "." : ""
    }
}

#Preview {
    VStack(spacing: PadelDesignTokens.Spacing.xxxl) {
        AuthLegalText(prefix: AuthCopy.Welcome.legalPrefix)
        AuthLegalText(prefix: AuthCopy.SignUp.termsPrefix, alignment: .leading)
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
