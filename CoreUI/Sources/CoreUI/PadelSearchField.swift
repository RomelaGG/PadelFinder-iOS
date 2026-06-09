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
    private let isFocused: FocusState<Bool>.Binding?

    public init(
        text: Binding<String>,
        placeholder: String = "Search clubs or area",
        isFocused: FocusState<Bool>.Binding? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isFocused = isFocused
    }

    public var body: some View {
        HStack(spacing: PadelDesignTokens.Spacing.xl) {
            Image(systemName: "magnifyingglass")
                .font(PadelDesignTokens.Fonts.symbol)
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                .accessibilityHidden(true)

            searchTextField

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

    @ViewBuilder
    private var searchTextField: some View {
        if let isFocused {
            textField
                .focused(isFocused)
        } else {
            textField
        }
    }

    private var textField: some View {
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
    }
}
