//
//  AuthUser.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// The signed-in person, as the backend describes them.
///
/// There is no avatar and no "email verified" flag, because the server sends
/// neither: an account only ever exists once its address has been proved, so
/// verified-ness is not a state a signed-in user can be in.
public struct AuthUser: Equatable, Sendable, Identifiable {
    public let id: String
    public let email: String?
    public let phone: String?
    public let displayName: String?
    public let providers: [AuthProvider]

    public init(
        id: String,
        email: String? = nil,
        phone: String? = nil,
        displayName: String? = nil,
        providers: [AuthProvider] = []
    ) {
        self.id = id
        self.email = email
        self.phone = phone
        self.displayName = displayName
        self.providers = providers
    }

    /// What the Account screen puts in the big line. A nickname is optional at
    /// sign-up, so most of the time this is the email address.
    public var title: String {
        if let displayName, !displayName.isEmpty { return displayName }
        if let email, !email.isEmpty { return email }

        return "Your account"
    }

    /// Shown under the title, but only when it is not already the title.
    public var subtitle: String? {
        guard let email, !email.isEmpty, email != title else { return nil }

        return email
    }

    /// Up to two characters for `AvatarView`. Taken from the nickname when
    /// there is one, otherwise from the email's local part.
    public var initials: String {
        let source = displayName?.isEmpty == false
            ? displayName!
            : (email?.split(separator: "@").first.map(String.init) ?? "")

        let words = source
            .split(whereSeparator: { $0 == " " || $0 == "." || $0 == "_" || $0 == "-" })
            .filter { !$0.isEmpty }

        switch words.count {
        case 0:
            return ""
        case 1:
            return String(words[0].prefix(2)).uppercased()
        default:
            return (String(words[0].prefix(1)) + String(words[1].prefix(1))).uppercased()
        }
    }
}
