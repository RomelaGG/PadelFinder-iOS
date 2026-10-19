//
//  ResendTimerButton.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - ResendTimerButton

/// "Resend code in 0:42", then "Resend code".
///
/// The countdown is passed in rather than ticked here: a `Timer` inside a view
/// dies when the view goes away and keeps running when the app is backgrounded,
/// neither of which is what a cooldown means. The view model owns it, which
/// also makes it testable.
public struct ResendTimerButton: View {
    private let secondsRemaining: Int
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        secondsRemaining: Int,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.secondsRemaining = secondsRemaining
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        if secondsRemaining > 0 {
            Text("Resend code in \(formattedCountdown)")
                .font(PadelDesignTokens.Fonts.caption)
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                .accessibilityLabel("Resend code available in \(secondsRemaining) seconds")
        } else {
            PadelButton(
                "Resend code",
                style: .tertiary,
                isEnabled: isEnabled,
                action: action
            )
        }
    }

    private var formattedCountdown: String {
        String(format: "%d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }
}

#Preview {
    VStack(spacing: PadelDesignTokens.Spacing.xxxl) {
        ResendTimerButton(secondsRemaining: 42) {}
        ResendTimerButton(secondsRemaining: 7) {}
        ResendTimerButton(secondsRemaining: 0) {}
        ResendTimerButton(secondsRemaining: 0, isEnabled: false) {}
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
