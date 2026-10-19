//
//  AuthProvider.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// How an account can be signed into.
///
/// Raw values match the backend's `providers` array exactly, so a new provider
/// on the server does not need a translation table here.
public enum AuthProvider: String, Equatable, Sendable, CaseIterable {
    case password
    case apple
    case google

    public var displayName: String {
        switch self {
        case .password: return "Email"
        case .apple:    return "Apple"
        case .google:   return "Google"
        }
    }
}
