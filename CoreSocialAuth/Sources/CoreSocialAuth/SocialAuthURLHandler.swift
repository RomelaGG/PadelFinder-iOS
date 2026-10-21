//
//  SocialAuthURLHandler.swift
//  CoreSocialAuth
//
//  Created by Giorgi Romelashvili on 21.10.26.
//

import Foundation
import GoogleSignIn

/// The app's hook for a provider's custom-scheme callback.
///
/// It exists so the app target can forward the URL without importing
/// `GoogleSignIn` itself - which is the point of this package. Recent SDK
/// versions run the flow inside `ASWebAuthenticationSession` and usually come
/// back without ever needing this, but when it *is* needed and missing the
/// only symptom is a sign-in that silently never returns.
public enum SocialAuthURLHandler {

    /// `true` when a provider recognised and consumed the URL.
    @MainActor
    @discardableResult
    public static func handle(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
