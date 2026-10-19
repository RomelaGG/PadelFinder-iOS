//
//  OTPPurpose.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// Why a 6-digit code was sent.
///
/// The code screen is one screen with two jobs, and the two differ in more
/// than wording: a sign-up code is checked by its own endpoint the moment the
/// sixth digit lands, while a reset code has no endpoint to check it against
/// and is only spent when the new password is saved.
public enum OTPPurpose: Hashable, Sendable {
    case verifyEmail
    case resetPassword

    /// Whether the code can be verified on its own, before the user does
    /// anything else.
    public var isVerifiableOnItsOwn: Bool {
        switch self {
        case .verifyEmail:   return true
        case .resetPassword: return false
        }
    }
}
