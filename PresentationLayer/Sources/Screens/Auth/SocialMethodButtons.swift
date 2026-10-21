//
//  SocialMethodButtons.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 21.10.26.
//

import CoreUI
import DesignSystem
import DomainLayer
import SwiftUI

/// Continue with Apple and Continue with Google, drawn the same way on all
/// three screens that offer them.
///
/// Its one piece of logic is reading `AuthFeatureFlags`: a provider that is
/// switched off still draws its button, pixel for pixel, but answers the tap
/// itself with "isn't available yet" instead of opening a sheet that is going
/// to fail. That is the whole reason `PadelAppleButton` ships two inits.
struct SocialMethodButtons: View {

    @ObservedObject private var social: SocialSignInModel

    /// Set by a screen that has its own work in flight - the email form on
    /// `SignInView`, say.
    private let isDisabled: Bool

    init(social: SocialSignInModel, isDisabled: Bool = false) {
        self.social = social
        self.isDisabled = isDisabled
    }

    var body: some View {
        VStack(spacing: PadelDesignTokens.Layout.fieldGap) {
            appleButton
                .disabled(isBusy)

            PadelSocialButton(
                provider: .google,
                isLoading: social.isBusy(.google)
            ) {
                social.signInWithGoogle()
            }
            .disabled(isBusy)
        }
    }

    @ViewBuilder
    private var appleButton: some View {
        if AuthFeatureFlags.isEnabled(.apple) {
            PadelAppleButton(
                onRequest: social.configure,
                onCompletion: social.completeApple
            )
        } else {
            PadelAppleButton { social.showUnavailable(.apple) }
        }
    }

    private var isBusy: Bool {
        isDisabled || social.isBusy
    }
}
