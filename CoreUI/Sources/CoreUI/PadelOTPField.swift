//
//  PadelOTPField.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelOTPField

/// Six boxes for a 6-digit code.
///
/// **One** hidden `TextField` carries the real text and the cells are drawn on
/// top of it. Six separate fields would look identical and break paste,
/// one-time-code autofill and VoiceOver all at once — which is exactly the
/// trade nobody notices until a user cannot sign in.
///
/// There is deliberately no submit button: `onComplete` fires when the last
/// digit lands. A button after a filled OTP field is a tap that carries no
/// information.
public struct PadelOTPField: View {
    @Binding private var code: String
    @FocusState private var internalFocus: Bool
    @State private var shakeProgress: CGFloat = 0
    @State private var caretIsVisible = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let length: Int
    private let hasError: Bool
    private let isEnabled: Bool
    private let externalFocus: FocusState<Bool>.Binding?
    private let onComplete: (String) -> Void

    public init(
        code: Binding<String>,
        length: Int = 6,
        hasError: Bool = false,
        isEnabled: Bool = true,
        isFocused: FocusState<Bool>.Binding? = nil,
        onComplete: @escaping (String) -> Void
    ) {
        self._code = code
        self.length = length
        self.hasError = hasError
        self.isEnabled = isEnabled
        self.externalFocus = isFocused
        self.onComplete = onComplete
    }

    public var body: some View {
        cells
            .background(alignment: .center) { hiddenField }
            .contentShape(Rectangle())
            .onTapGesture { focusBinding.wrappedValue = true }
            .modifier(ShakeEffect(progress: shakeProgress))
            .opacity(reduceMotion && hasError ? 0.6 : 1)
            .allowsHitTesting(isEnabled)
            .onChange(of: hasError) { reactToError($0) }
            .onAppear { startCaretBlink() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "Verification code, \(code.count) of \(length) digits entered"
            )
            .accessibilityValue(code)
    }
}

// MARK: - Pieces

private extension PadelOTPField {

    var focusBinding: FocusState<Bool>.Binding { externalFocus ?? $internalFocus }

    var isFocused: Bool { externalFocus?.wrappedValue ?? internalFocus }

    var cells: some View {
        HStack(spacing: PadelDesignTokens.Spacing.xl) {
            ForEach(0..<length, id: \.self) { index in
                cell(at: index)
            }
        }
    }

    func cell(at index: Int) -> some View {
        let digit = index < code.count ? String(Array(code)[index]) : ""
        let isNextToFill = isFocused && index == code.count && isEnabled

        return ZStack {
            Text(digit)
                .font(PadelDesignTokens.Fonts.otpDigit)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)

            if isNextToFill, digit.isEmpty {
                RoundedRectangle(cornerRadius: 1)
                    .fill(PadelDesignTokens.Colors.accent)
                    .frame(width: 2, height: 26)
                    .opacity(caretIsVisible ? 1 : 0)
            }
        }
        .frame(
            width: PadelDesignTokens.Sizing.otpCellWidth,
            height: PadelDesignTokens.Sizing.otpCellHeight
        )
        .background(fillColor(digit: digit, isNextToFill: isNextToFill))
        .clipShape(cellShape)
        .overlay {
            cellShape.stroke(
                borderColor(digit: digit, isNextToFill: isNextToFill),
                lineWidth: borderWidth(isNextToFill: isNextToFill)
            )
        }
        .animation(.easeOut(duration: PadelDesignTokens.Motion.fast), value: isNextToFill)
    }

    /// Carries the real text, the number pad and the one-time-code content type
    /// — invisible but present, because an actually-hidden field cannot be
    /// focused and would take no autofill.
    var hiddenField: some View {
        TextField("", text: $code)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .focused(focusBinding)
            .opacity(0.01)
            .frame(width: 1, height: 1)
            .accessibilityHidden(true)
            .onChange(of: code) { sanitise($0) }
    }

    var cellShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.l, style: .continuous)
    }

    func fillColor(digit: String, isNextToFill: Bool) -> Color {
        if hasError { return PadelDesignTokens.Colors.errorSurface }
        if isNextToFill { return PadelDesignTokens.Colors.accentSurface }

        return digit.isEmpty
            ? PadelDesignTokens.Colors.surfaceMuted
            : PadelDesignTokens.Colors.surface
    }

    func borderColor(digit: String, isNextToFill: Bool) -> Color {
        if hasError { return PadelDesignTokens.Colors.error }
        if isNextToFill { return PadelDesignTokens.Colors.accent }

        return digit.isEmpty
            ? PadelDesignTokens.Colors.border
            : PadelDesignTokens.Colors.borderStrong
    }

    func borderWidth(isNextToFill: Bool) -> CGFloat {
        hasError || isNextToFill ? 1.5 : PadelDesignTokens.Sizing.hairline
    }

    // MARK: Behaviour

    /// Digits only, never longer than `length`. A pasted "Your code is 123456"
    /// becomes "123456" rather than being rejected.
    func sanitise(_ newValue: String) {
        let digits = String(newValue.filter(\.isNumber).prefix(length))

        if digits != newValue {
            code = digits
            return
        }

        if digits.count == length {
            onComplete(digits)
        }
    }

    func reactToError(_ hasError: Bool) {
        guard hasError else { return }

        // Cleared so retyping starts from an empty row rather than the user
        // having to delete six wrong digits first.
        code = ""

        guard !reduceMotion else { return }

        withAnimation(.linear(duration: PadelDesignTokens.Motion.shakeDuration)) {
            shakeProgress += 1
        }
    }

    func startCaretBlink() {
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            caretIsVisible = false
        }
    }
}

// MARK: - ShakeEffect

/// Three oscillations of ±8pt, driven by one animatable value so the whole
/// shake is a single `withAnimation` rather than a chain of delays.
private struct ShakeEffect: GeometryEffect {
    var travel: CGFloat = 8
    var oscillations: CGFloat = 3
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = travel * sin(progress * .pi * 2 * oscillations)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var empty = ""
        @State private var partial = "123"
        @State private var full = "123456"

        var body: some View {
            VStack(spacing: PadelDesignTokens.Spacing.xxxl) {
                PadelOTPField(code: $empty) { _ in }
                PadelOTPField(code: $partial) { _ in }
                PadelOTPField(code: $full) { _ in }
                PadelOTPField(code: .constant("9999"), hasError: true) { _ in }
                PadelOTPField(code: .constant("12"), isEnabled: false) { _ in }
            }
            .padding()
            .background(PadelDesignTokens.Colors.background)
        }
    }

    return PreviewHost()
}
