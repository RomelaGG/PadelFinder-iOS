//
//  AuthErrorMapper.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNetworking
import DomainLayer

protocol AuthErrorMapperProtocol: Sendable {
    func map(_ error: NetworkError) -> AuthDomainError
}

/// The only place in the app that knows the server's error codes as strings.
struct AuthErrorMapper: AuthErrorMapperProtocol {

    /// Mirrors the backend's `AuthErrorCode`. `codeExpired` is declared there
    /// but never thrown - an expired code arrives as `invalid_code` - so it is
    /// folded into the same case here rather than given a state of its own
    /// that nothing can reach.
    private enum Code {
        static let invalidCredentials = "invalid_credentials"
        static let emailNotVerified = "email_not_verified"
        static let invalidCode = "invalid_code"
        static let codeExpired = "code_expired"
        static let codeBurned = "code_burned"
        static let tooManyRequests = "too_many_requests"
        static let invalidToken = "invalid_token"
        static let sessionRevoked = "session_revoked"
        static let emailAlreadyInUse = "email_already_in_use"
        static let identityVerificationFailed = "identity_verification_failed"
        static let providerNotConfigured = "provider_not_configured"
        static let validationFailed = "validation_failed"
        static let emailSendFailed = "email_send_failed"
    }

    func map(_ error: NetworkError) -> AuthDomainError {
        switch error {
        case .noInternet:
            return .offline

        case .timeout:
            return .timeout

        case .serverError:
            return .server

        case let .apiError(apiError):
            return map(apiError)

        case .invalidRequest, .decodingFailed, .unauthorized, .forbidden, .notFound, .unknown:
            // A bare 401 with no envelope is deliberately *not* treated as an
            // expired session. Only a coded refusal signs anybody out, so an
            // edge or proxy hiccup cannot sign out every user at once.
            return .unknown
        }
    }

    private func map(_ error: APIError) -> AuthDomainError {
        guard let code = error.code else {
            // No code means Vapor's own middleware answered: a validation
            // failure, an undecodable body, or a 500. Its prose names field
            // keys, so it is never shown.
            switch error.statusCode {
            case 500...: return .server
            case 400:    return .validationFailed(reason: nil)
            default:     return .unknown
            }
        }

        switch code {
        case Code.invalidCredentials:
            return .invalidCredentials(reason: error.reason)

        case Code.emailNotVerified:
            return .emailNotVerified(reason: error.reason)

        case Code.invalidCode, Code.codeExpired:
            return .invalidCode(reason: error.reason)

        case Code.codeBurned:
            return .codeBurned(reason: error.reason)

        case Code.tooManyRequests:
            return .tooManyRequests(reason: error.reason)

        case Code.invalidToken, Code.sessionRevoked:
            // The token store has already cleared the session by the time one
            // of these surfaces here, so the screen only has to get out of
            // the way.
            return .sessionExpired

        case Code.emailAlreadyInUse:
            return .emailAlreadyInUse(reason: error.reason)

        case Code.identityVerificationFailed:
            return .identityVerificationFailed(reason: error.reason)

        case Code.providerNotConfigured:
            return .providerNotConfigured(reason: error.reason)

        case Code.validationFailed:
            return .validationFailed(reason: error.reason)

        case Code.emailSendFailed:
            return .emailSendFailed(reason: error.reason)

        default:
            return .unknown
        }
    }
}
