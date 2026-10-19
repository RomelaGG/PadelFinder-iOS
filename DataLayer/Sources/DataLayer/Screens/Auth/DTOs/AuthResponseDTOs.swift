//
//  AuthResponseDTOs.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// A freshly minted session, as `/auth/login`, `/auth/otp/verify`,
/// `/auth/refresh` and the two provider endpoints all return it.
struct TokenResponseDTO: Decodable, Equatable, Sendable {
    let accessToken: String

    /// Seconds. 900 today.
    let expiresIn: Int

    /// Opaque, not a JWT, and rotated on every use.
    let refreshToken: String

    /// The server sends the profile inline, so a successful sign-in needs no
    /// follow-up call to `/auth/me`.
    let user: UserResponseDTO
}

struct UserResponseDTO: Decodable, Equatable, Sendable {
    let id: String
    let email: String?
    let phone: String?
    let displayName: String?

    /// Subset of `["apple", "google", "password"]`, alphabetical.
    let providers: [String]
}

/// `{"status": "accepted"}` - the answer to every endpoint that only promises
/// to have sent an email.
struct AcceptedResponseDTO: Decodable, Equatable, Sendable {
    let status: String
}
