//
//  StoredAuthSession.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DomainLayer
import Foundation

/// What survives app launches, as one Keychain item.
///
/// The refresh token and the cached profile travel together deliberately: one
/// read on cold launch gives the Account tab everything it needs to render,
/// one write keeps the two consistent, and it becomes structurally impossible
/// for the stored token and the stored user to disagree about who is signed in.
///
/// The access token is **not** here. It lives for 15 minutes and is kept in
/// memory only.
struct StoredAuthSession: Codable, Equatable, Sendable {
    let refreshToken: String
    let user: StoredAuthUser
    let savedAt: Date
}

struct StoredAuthUser: Codable, Equatable, Sendable {
    let id: String
    let email: String?
    let phone: String?
    let displayName: String?
    let providers: [String]

    init(_ user: AuthUser) {
        self.id = user.id
        self.email = user.email
        self.phone = user.phone
        self.displayName = user.displayName
        self.providers = user.providers.map(\.rawValue)
    }

    var domainUser: AuthUser {
        AuthUser(
            id: id,
            email: email,
            phone: phone,
            displayName: displayName,
            providers: providers.compactMap(AuthProvider.init(rawValue:))
        )
    }
}
