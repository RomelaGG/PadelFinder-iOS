//
//  APIError.swift
//  CoreNetworking
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Foundation

/// The body the backend sends on a refused request.
///
/// `/auth/*` answers with all three fields. Every other route - and any
/// validation failure - goes through Vapor's own `ErrorMiddleware`, which omits
/// `code`. That is why `code` is optional, and why a response without one is
/// never treated as a recognised, actionable failure.
public struct APIErrorEnvelope: Decodable, Sendable, Equatable {
    public let error: Bool?
    public let code: String?
    public let reason: String

    public init(error: Bool?, code: String?, reason: String) {
        self.error = error
        self.code = code
        self.reason = reason
    }
}

/// A refusal the server described well enough to act on.
public struct APIError: Error, Sendable, Equatable {
    /// HTTP status that carried the envelope.
    public let statusCode: Int

    /// Stable snake_case identifier - `invalid_credentials`, `invalid_code`,
    /// `too_many_requests`. `nil` when the response had no `code` field, which
    /// means the text is Vapor's and must not be shown to a user.
    public let code: String?

    /// Human sentence written by the backend. Shown verbatim when `code` is
    /// present: for OTP failures it is the only place the remaining-attempt
    /// count exists.
    public let reason: String

    public init(statusCode: Int, code: String?, reason: String) {
        self.statusCode = statusCode
        self.code = code
        self.reason = reason
    }

    /// Whether this refusal is safe to show to the user as-is.
    public var isActionable: Bool { code != nil }
}
