//
//  GoogleCredentialProviding.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 21.10.26.
//

/// Gets a Google OIDC `id_token` from the device, so the rest of the app can
/// treat Continue with Google as one `await`.
///
/// Declared here and implemented in `CoreSocialAuth`, the same shape as
/// `AuthRepositoryProtocol` (declared here, implemented in `DataLayer`). That
/// is what keeps Google's SDK and its three transitive dependencies out of
/// `PresentationLayer`, which every screen in the app lives in.
///
/// Note what the protocol does *not* take: no view controller, no window.
/// Finding something to present from is the implementation's problem, because
/// `DomainLayer` imports neither UIKit nor SwiftUI anywhere and should not
/// start now.
@MainActor
public protocol GoogleCredentialProviding: Sendable {

    /// Presents Google's sheet and returns an `id_token` carrying `nonce`.
    ///
    /// `nil` means the user cancelled - a plain outcome, not a failure, and
    /// the one case the UI must say nothing about. Modelling it as a value
    /// rather than an error keeps `AuthDomainError` free of a case that no
    /// screen is ever allowed to display.
    func identityToken(nonce: String) async throws -> String?
}

// MARK: - SocialCredentialError

/// Failures that happen on the device, before the server is ever called.
///
/// Cancellation is deliberately absent: it comes back as `nil` from
/// `identityToken(nonce:)`, because it is an outcome rather than a fault and
/// the UI must stay silent about it.
public enum SocialCredentialError: Error, Equatable, Sendable {

    /// No client id on the device - `GIDClientID` is missing from Info.plist.
    /// Only reachable by a misconfigured build, never by a user.
    case notConfigured

    /// Nothing on screen to present the provider's sheet from.
    case noPresenter

    /// The provider completed but handed back no `id_token`. Not a
    /// cancellation, and must never be reported as one.
    case missingIdentityToken
}
