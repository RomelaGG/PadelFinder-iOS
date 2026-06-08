//
//  PadelSearchField.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

import DesignSystem
import SwiftUI

public struct PadelSearchField: View {
    @Binding private var text: String

    private let placeholder: String

    public init(
        text: Binding<String>,
        placeholder: String = "Search clubs or area"
    ) {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        HStack(spacing: PadelDesignTokens.Spacing.xl) {
            Image(systemName: "magnifyingglass")
                .font(PadelDesignTokens.Fonts.symbol)
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                .accessibilityHidden(true)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .font(PadelDesignTokens.Fonts.input)
                    .foregroundColor(PadelDesignTokens.Colors.textSecondary)
            )
                .font(PadelDesignTokens.Fonts.input)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                .tint(PadelDesignTokens.Colors.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(PadelDesignTokens.Fonts.bodyStrong)
                        .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
        .frame(height: PadelDesignTokens.Sizing.actionControl)
        .background(PadelDesignTokens.Colors.surfaceMuted)
        .clipShape(shape)
        .overlay {
            shape
                .stroke(PadelDesignTokens.Colors.border, lineWidth: PadelDesignTokens.Sizing.hairline)
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xl, style: .continuous)
    }
}
