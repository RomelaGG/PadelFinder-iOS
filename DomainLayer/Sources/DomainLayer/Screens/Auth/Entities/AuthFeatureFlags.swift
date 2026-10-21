//
//  AuthFeatureFlags.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// Which sign-in methods are actually usable right now.
///
/// Apple and Google are built end to end - request, DTO, data source,
/// repository, use case, and the credential plumbing in `SocialSignInModel`.
/// What these flags still guard is the configuration each one needs *outside*
/// this codebase, because a provider whose config is missing answers `503
/// provider_not_configured`, and that is a worse way to learn the option is
/// not ready than a sentence saying so.
///
/// Apple is on. It needs two things, both done: the
/// `com.apple.developer.applesignin` entitlement with the matching capability
/// enabled on the App ID, and `APPLE_CLIENT_IDS=GR.PadelFinder` on the server.
///
/// Google is off until it has an iOS OAuth client id from Google Cloud
/// Console, which three places need to agree on: `GOOGLE_CLIENT_IDS` on the
/// server, `GIDClientID` in `PadelFinderInfo.plist`, and the reversed form in
/// that file's `CFBundleURLSchemes`. Flip this the moment those are in place;
/// nothing else changes. Note that App Store Guideline 4.8 obliges us to keep
/// offering Sign in with Apple alongside it, which we do.
public enum AuthFeatureFlags {
    public static let appleSignInEnabled = true
    public static let googleSignInEnabled = false

    public static func isEnabled(_ provider: AuthProvider) -> Bool {
        switch provider {
        case .apple:    return appleSignInEnabled
        case .google:   return googleSignInEnabled
        case .password: return true
        }
    }
}
