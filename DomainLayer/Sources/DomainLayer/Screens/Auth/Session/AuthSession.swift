//
//  AuthSession.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Combine

/// Who is signed in — the single source of truth.
///
/// Every screen that branches on sign-in reads this one object. Keeping a
/// local copy anywhere is how two parts of the app end up disagreeing about
/// whether there is an account.
///
/// Lives in the domain layer rather than the presentation layer because both
/// sides have to reach it: the sign-in path writes to it, and so does the
/// token store when a refresh comes back revoked. `ObservableObject` is
/// Combine, not SwiftUI, so this does not drag a UI framework down here.
@MainActor
public final class AuthSession: ObservableObject {

    public enum State: Equatable {
        /// The app has just launched and the Keychain has not been read yet.
        /// Rendering the signed-out promo during this would flash the wrong
        /// answer at a user who is, in fact, signed in.
        case unknown
        case signedOut
        case signedIn(AuthUser)
    }

    @Published public private(set) var state: State = .unknown

    /// `nonisolated` because Swinject's factory closures are not isolated to
    /// any actor, and this initialiser only assigns a `Sendable` value.
    public nonisolated init() { }

    public var isSignedIn: Bool {
        if case .signedIn = state { return true }

        return false
    }

    public var currentUser: AuthUser? {
        if case let .signedIn(user) = state { return user }

        return nil
    }

    // MARK: - Writes
    //
    // Only the repository and the token store call these. Views read `state`.

    public func signedIn(_ user: AuthUser) {
        state = .signedIn(user)
    }

    /// Updates the stored profile without disturbing the signed-in state.
    /// A no-op when nobody is signed in, so a late `GET /auth/me` landing
    /// after a sign-out cannot bring the user back.
    public func updateUser(_ user: AuthUser) {
        guard isSignedIn else { return }

        state = .signedIn(user)
    }

    public func signedOut() {
        state = .signedOut
    }
}
