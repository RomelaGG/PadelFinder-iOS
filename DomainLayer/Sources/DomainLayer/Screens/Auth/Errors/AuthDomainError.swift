//
//  AuthDomainError.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Foundation

/// Every way an account operation can fail, in the vocabulary the screens
/// think in.
///
/// Each coded case carries the sentence the backend wrote. That is deliberate:
/// for a wrong 6-digit code the server says "That code is not correct. 3
/// attempts left." and the attempt count exists *only* inside that sentence —
/// there is no separate field for it. Rewriting the copy here would silently
/// throw the count away.
///
/// The cases with no `reason` are the ones the server never described, so the
/// copy below is ours.
public enum AuthDomainError: Error, Equatable, Sendable, LocalizedError {

    // Coded refusals - text comes from the server.
    case invalidCredentials(reason: String)
    case emailNotVerified(reason: String)
    case invalidCode(reason: String)
    case codeBurned(reason: String)
    case tooManyRequests(reason: String)
    case emailAlreadyInUse(reason: String)
    case identityVerificationFailed(reason: String)
    case providerNotConfigured(reason: String)
    case emailSendFailed(reason: String)
    case validationFailed(reason: String?)

    // Our own.

    /// The session is already gone and the user has already been signed out.
    /// A screen seeing this should get out of the way, not explain itself.
    case sessionExpired

    /// The new password was saved, but the sign-in that normally follows it
    /// did not go through. Saying nothing would be a lie; saying "something
    /// went wrong" would make the user think the reset failed.
    case passwordSavedButSignInFailed

    case socialSignInUnavailable(AuthProvider)
    case offline
    case timeout
    case server
    case unknown

    public var errorDescription: String? {
        switch self {
        case let .invalidCredentials(reason),
             let .emailNotVerified(reason),
             let .invalidCode(reason),
             let .codeBurned(reason),
             let .tooManyRequests(reason),
             let .emailAlreadyInUse(reason),
             let .identityVerificationFailed(reason),
             let .providerNotConfigured(reason),
             let .emailSendFailed(reason):
            return reason

        case let .validationFailed(reason):
            // A validation failure arrives through Vapor's own middleware with
            // no code, and its prose names field keys ("password is less than
            // minimum of 8 character(s)"). Not for a user to read.
            return reason ?? "Please check the details you entered."

        case .sessionExpired:
            return "Your session has expired. Please sign in again."

        case .passwordSavedButSignInFailed:
            return "Your new password is saved. Sign in with it to continue."

        case let .socialSignInUnavailable(provider):
            return "Signing in with \(provider.displayName) isn't available yet."

        case .offline:
            return "No internet connection."

        case .timeout:
            return "Request timed out. Please try again."

        case .server, .unknown:
            return "Something went wrong. Please try again."
        }
    }

    /// Whether retrying the same thing could plausibly work. Drives whether a
    /// banner offers a "Try again" action.
    public var isRetryable: Bool {
        switch self {
        case .offline, .timeout, .server, .emailSendFailed:
            return true
        default:
            return false
        }
    }

    /// `true` for the two failures that mean the code the user holds is dead
    /// and they need a new one.
    public var requiresNewCode: Bool {
        switch self {
        case .invalidCode, .codeBurned: return true
        default:                        return false
        }
    }
}
