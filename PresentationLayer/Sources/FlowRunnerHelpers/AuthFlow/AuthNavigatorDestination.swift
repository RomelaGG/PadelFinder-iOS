//
//  AuthNavigatorDestination.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import DomainLayer
import SwiftUI

enum AuthNavigatorDestination: NavigatorDestination {
    case signUp

    /// Carries an email so the sign-in form can arrive pre-filled — from the
    /// sign-up footer, or from the code screen when the address turns out to
    /// already have an account.
    case signIn(email: String?)

    case verifyCode(email: String, purpose: OTPPurpose)
    case forgotPassword(email: String?)
    case newPassword(email: String, code: String)
    case success(email: String?)

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .signUp:
            SignUpView(viewModel: .init(state: .init()))

        case let .signIn(email):
            SignInView(viewModel: .init(state: .init(email: email ?? "")))

        case let .verifyCode(email, purpose):
            VerifyCodeView(viewModel: .init(state: .init(email: email, purpose: purpose)))

        case let .forgotPassword(email):
            ForgotPasswordView(viewModel: .init(state: .init(email: email ?? "")))

        case let .newPassword(email, code):
            NewPasswordView(viewModel: .init(state: .init(email: email, code: code)))

        case let .success(email):
            AuthSuccessView(email: email)
        }
    }
}
