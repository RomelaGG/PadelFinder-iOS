//
//  PadelTextField.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelTextField

/// A labelled input.
///
/// `kind` is the whole point of the type: it sets the keyboard, the content
/// type and the autocapitalisation together, so a field can never end up with
/// an email keyboard and a password content type. Getting that combination
/// right is most of what makes a form feel native.
public struct PadelTextField: View {

    public enum Kind {
        case plain
        case email
        case password
        case newPassword
        case phone
        case name
    }

    @Binding private var text: String
    @FocusState private var internalFocus: Bool
    @State private var isSecureTextVisible = false

    private let label: String
    private let placeholder: String
    private let kind: Kind
    private let errorText: String?
    private let helperText: String?
    private let isEnabled: Bool
    private let submitLabel: SubmitLabel
    private let externalFocus: FocusState<Bool>.Binding?
    private let onSubmit: (() -> Void)?

    public init(
        _ label: String,
        text: Binding<String>,
        placeholder: String = "",
        kind: Kind = .plain,
        errorText: String? = nil,
        helperText: String? = nil,
        isEnabled: Bool = true,
        submitLabel: SubmitLabel = .next,
        isFocused: FocusState<Bool>.Binding? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.kind = kind
        self.errorText = errorText
        self.helperText = helperText
        self.isEnabled = isEnabled
        self.submitLabel = submitLabel
        self.externalFocus = isFocused
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.s) {
            Text(label)
                .font(PadelDesignTokens.Fonts.label)
                .foregroundStyle(PadelDesignTokens.Colors.textSupport)

            fieldBox

            footnote
        }
        .animation(.easeOut(duration: PadelDesignTokens.Motion.standard), value: errorText)
    }
}

// MARK: - Pieces

private extension PadelTextField {

    var focusBinding: FocusState<Bool>.Binding { externalFocus ?? $internalFocus }

    var isFocused: Bool { externalFocus?.wrappedValue ?? internalFocus }

    var hasError: Bool { errorText != nil }

    var fieldBox: some View {
        HStack(spacing: PadelDesignTokens.Spacing.l) {
            input

            if kind.isSecure {
                revealButton
            }
        }
        .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
        .frame(height: PadelDesignTokens.Sizing.actionControl)
        .background(fillColor)
        .clipShape(shape)
        .overlay {
            shape.stroke(borderColor, lineWidth: borderWidth)
        }
        // Drawn outside the box, so it reads as a halo rather than a thicker
        // border. 3pt as specified; `focusRing` is already accent at 25%.
        .overlay {
            shape
                .stroke(PadelDesignTokens.Colors.focusRing, lineWidth: 3)
                .opacity(isFocused && !hasError ? 1 : 0)
                .padding(-1.5)
        }
        .animation(.easeOut(duration: PadelDesignTokens.Motion.fast), value: isFocused)
        .allowsHitTesting(isEnabled)
    }

    @ViewBuilder
    var input: some View {
        let prompt = Text(placeholder)
            .font(PadelDesignTokens.Fonts.input)
            .foregroundColor(PadelDesignTokens.Colors.textSecondary)

        Group {
            if kind.isSecure, !isSecureTextVisible {
                SecureField("", text: $text, prompt: prompt)
            } else {
                TextField("", text: $text, prompt: prompt)
            }
        }
        .font(PadelDesignTokens.Fonts.input)
        .foregroundStyle(
            isEnabled
                ? PadelDesignTokens.Colors.textPrimary
                : PadelDesignTokens.Colors.textDisabled
        )
        .tint(PadelDesignTokens.Colors.accent)
        .focused(focusBinding)
        .submitLabel(submitLabel)
        .onSubmit { onSubmit?() }
        .keyboardType(kind.keyboardType)
        .textContentType(kind.contentType)
        .textInputAutocapitalization(kind.autocapitalization)
        .autocorrectionDisabled(kind.disablesAutocorrection)
        .accessibilityLabel(label)
    }

    var revealButton: some View {
        Button {
            isSecureTextVisible.toggle()

            // Swapping SecureField for TextField replaces the view and drops
            // the keyboard with it. One hop later, focus is re-asserted so
            // typing carries on where it left off.
            Task { @MainActor in
                focusBinding.wrappedValue = true
            }
        } label: {
            Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
                .font(PadelDesignTokens.Fonts.symbol)
                .foregroundStyle(PadelDesignTokens.Colors.textSupport)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSecureTextVisible ? "Hide password" : "Show password")
    }

    /// Always one line tall, whether or not there is anything to say. The
    /// alternative is a form that jumps every time an error appears.
    var footnote: some View {
        Text(errorText ?? helperText ?? " ")
            .font(PadelDesignTokens.Fonts.caption)
            .foregroundStyle(
                hasError
                    ? PadelDesignTokens.Colors.error
                    : PadelDesignTokens.Colors.textSupport
            )
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityHidden(errorText == nil && helperText == nil)
    }

    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xl, style: .continuous)
    }

    var fillColor: Color {
        guard isEnabled else { return PadelDesignTokens.Colors.surfaceMuted }

        return isFocused || hasError
            ? PadelDesignTokens.Colors.surface
            : PadelDesignTokens.Colors.surfaceMuted
    }

    var borderColor: Color {
        if hasError { return PadelDesignTokens.Colors.error }
        if isFocused, isEnabled { return PadelDesignTokens.Colors.accent }

        return PadelDesignTokens.Colors.border
    }

    var borderWidth: CGFloat {
        hasError || (isFocused && isEnabled) ? 1.5 : PadelDesignTokens.Sizing.hairline
    }
}

// MARK: - Kind table

private extension PadelTextField.Kind {

    var isSecure: Bool {
        switch self {
        case .password, .newPassword: return true
        default:                      return false
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .email: return .emailAddress
        case .phone: return .phonePad
        default:     return .default
        }
    }

    /// `.newPassword` deliberately reports itself as `.password`.
    ///
    /// `UITextContentType.newPassword` is what triggers iOS's Automatic Strong
    /// Passwords sheet - the "Use Strong Password?" card that takes over the
    /// screen the moment the field is focused. We do not want it interrupting
    /// sign-up, so the field claims the plainer type. The cost is only that iOS
    /// no longer offers to *generate* a password; filling and saving still work.
    ///
    /// Do not try `nil` here to get rid of the Passwords key in the QuickType
    /// bar. That was measured on iOS 16.4 and iOS 26 and the key stayed on
    /// both: it is driven by the field being a `SecureField` at all, not by
    /// this type, and no public API suppresses it. Nil only costs AutoFill on
    /// sign-in, filling by third-party password managers, and the system's
    /// offer to save - buying nothing. The only way to lose the key is to stop
    /// using `SecureField` and mask the text by hand, which is not worth it.
    var contentType: UITextContentType? {
        switch self {
        case .plain:                  return nil
        case .email:                  return .emailAddress
        case .password, .newPassword: return .password
        case .phone:                  return .telephoneNumber
        case .name:                   return .name
        }
    }

    var autocapitalization: TextInputAutocapitalization {
        switch self {
        case .plain: return .sentences
        case .name:  return .words
        default:     return .never
        }
    }

    var disablesAutocorrection: Bool {
        switch self {
        case .plain: return false
        default:     return true
        }
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var email = ""
        @State private var password = "hunter2hunter"
        @State private var nickname = "Gio"

        var body: some View {
            ScrollView {
                VStack(spacing: PadelDesignTokens.Spacing.xl) {
                    PadelTextField("Email", text: $email, kind: .email)

                    PadelTextField(
                        "Email",
                        text: .constant("not-an-email"),
                        kind: .email,
                        errorText: "Enter a valid email address."
                    )

                    PadelTextField("Password", text: $password, kind: .password)

                    PadelTextField(
                        "Nickname",
                        text: $nickname,
                        kind: .name,
                        helperText: "How other players will see you"
                    )

                    PadelTextField(
                        "Email",
                        text: .constant("you@example.com"),
                        kind: .email,
                        isEnabled: false
                    )
                }
                .padding()
            }
            .background(PadelDesignTokens.Colors.background)
        }
    }

    return PreviewHost()
}
