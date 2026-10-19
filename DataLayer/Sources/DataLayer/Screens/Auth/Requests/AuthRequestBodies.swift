//
//  AuthRequestBodies.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// The JSON bodies the auth endpoints expect.
///
/// Field names are the wire names: the backend runs Vapor's default coder with
/// no key strategy, so these are sent camelCase exactly as written. Optional
/// properties are synthesised with `encodeIfPresent`, so a `nil` nickname is
/// omitted rather than sent as `null`.
struct RegisterBody: Encodable, Sendable {
    let email: String
    let password: String
    let displayName: String?
}

struct LoginBody: Encodable, Sendable {
    let email: String
    let password: String
}

struct EmailBody: Encodable, Sendable {
    let email: String
}

struct VerifyCodeBody: Encodable, Sendable {
    let email: String
    let code: String
}

struct ResetPasswordBody: Encodable, Sendable {
    let email: String
    let code: String
    let newPassword: String
}

struct RefreshBody: Encodable, Sendable {
    let refreshToken: String
}

struct AppleSignInBody: Encodable, Sendable {
    let identityToken: String
    let nonce: String?
    let displayName: String?
}

struct GoogleSignInBody: Encodable, Sendable {
    let identityToken: String
    let nonce: String?
}

struct UpdateProfileBody: Encodable, Sendable {
    let displayName: String?
    let phone: String?
}
