//
//  PadelCheckbox.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelCheckbox

/// A tick box with arbitrary label content, so the label can carry inline
/// links (Terms, Privacy) that a plain `Toggle` could not.
///
/// The whole row is the hit target, not just the 22pt box — a 22pt tap target
/// fails the 44pt minimum and is genuinely hard to hit.
public struct PadelCheckbox<Label: View>: View {
    @Binding private var isOn: Bool

    private let label: Label

    public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self._isOn = isOn
        self.label = label()
    }

    public var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(alignment: .top, spacing: PadelDesignTokens.Spacing.l) {
                box

                label
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }

    private var box: some View {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.s, style: .continuous)
            .fill(isOn ? PadelDesignTokens.Colors.accent : PadelDesignTokens.Colors.surface)
            .frame(
                width: PadelDesignTokens.Sizing.checkbox,
                height: PadelDesignTokens.Sizing.checkbox
            )
            .overlay {
                RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.s, style: .continuous)
                    .stroke(
                        isOn ? .clear : PadelDesignTokens.Colors.borderStrong,
                        lineWidth: PadelDesignTokens.Sizing.hairline
                    )
            }
            .overlay {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(PadelDesignTokens.Colors.onAccent)
                    .scaleEffect(isOn ? 1 : 0.4)
                    .opacity(isOn ? 1 : 0)
            }
            .animation(.easeOut(duration: PadelDesignTokens.Motion.fast), value: isOn)
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var accepted = false

        var body: some View {
            VStack(spacing: PadelDesignTokens.Spacing.xxxl) {
                PadelCheckbox(isOn: $accepted) {
                    Text("I agree to the Terms of Service and Privacy Policy")
                        .font(PadelDesignTokens.Fonts.caption)
                        .foregroundStyle(PadelDesignTokens.Colors.textSupport)
                }

                PadelCheckbox(isOn: .constant(true)) {
                    Text("Remember me")
                        .font(PadelDesignTokens.Fonts.caption)
                        .foregroundStyle(PadelDesignTokens.Colors.textSupport)
                }
            }
            .padding()
            .background(PadelDesignTokens.Colors.background)
        }
    }

    return PreviewHost()
}
