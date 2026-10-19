//
//  AuthTokens.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// A freshly issued token pair.
///
/// Declared here because `DataLayer` needs a shared vocabulary for it, but
/// nothing above `DataLayer` ever receives one: tokens stop at the repository,
/// and the presentation layer only ever learns about `AuthUser`.
public struct AuthTokens: Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String

    /// Seconds the access token is good for — 900 today.
    public let expiresIn: Int

    public init(accessToken: String, refreshToken: String, expiresIn: Int) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
    }
}
