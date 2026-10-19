//
//  AuthTokenProviding.swift
//  CoreNetworking
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Foundation

/// The only seam between transport and the type that owns the tokens.
///
/// Implemented in `DataLayer` by an actor that can reach the refresh endpoint.
/// `CoreNetworking` therefore never learns what a refresh request looks like,
/// and `DataLayer` never reaches inside the Alamofire session.
public protocol AuthTokenProviding: Sendable {

    /// Bearer for the next request, refreshing first when the cached access
    /// token is missing or inside its expiry leeway.
    ///
    /// `nil` means there is no session - send the request unauthenticated.
    func accessToken() async throws -> String?

    /// Single-flight refresh after a 401.
    ///
    /// `staleToken` is the value the caller actually sent. When somebody else
    /// has already refreshed in the meantime, the fresh token is returned
    /// without burning a second rotation - and with a rotating refresh token,
    /// a redundant rotation signs the whole device family out.
    ///
    /// `nil` means the session is gone and the caller must not retry.
    func refreshedAccessToken(after staleToken: String?) async throws -> String?
}
