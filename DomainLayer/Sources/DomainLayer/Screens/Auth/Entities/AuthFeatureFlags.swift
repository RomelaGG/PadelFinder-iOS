//
//  AuthFeatureFlags.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// Which sign-in methods are actually usable right now.
///
/// Apple and Google are built end to end — request, DTO, data source,
/// repository, use case — but switched off, because two things outside this
/// codebase are missing: the app has no entitlements file, so Sign in with
/// Apple cannot be granted, and the server has no `APPLE_CLIENT_IDS` /
/// `GOOGLE_CLIENT_IDS`, so both endpoints answer `provider_not_configured`.
///
/// Turning either on is this one flag plus the credential plumbing in the
/// view. No call site in the domain or data layers changes.
public enum AuthFeatureFlags {
    public static let appleSignInEnabled = false
    public static let googleSignInEnabled = false

    public static func isEnabled(_ provider: AuthProvider) -> Bool {
        switch provider {
        case .apple:    return appleSignInEnabled
        case .google:   return googleSignInEnabled
        case .password: return true
        }
    }
}
