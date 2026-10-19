//
//  TokenStore.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNetworking
import DomainLayer
import Foundation
import OSLog

enum AuthTokenError: Error {
    case signedOut
}

/// Owns the tokens, and allows exactly one refresh at a time.
///
/// The one-at-a-time rule is the whole reason this is an actor. Refresh tokens
/// rotate: the server kills the token the moment it is spent, and treats a
/// second use of a spent token as theft by revoking the entire device family.
/// So two concurrent refreshes do not merely waste a call - the second one
/// signs the user out. Four screens loading at once and all hitting a 401 is
/// the ordinary case, not an edge case.
actor TokenStore: AuthTokenProviding {

    /// Refreshed this far before expiry, to absorb clock skew and the latency
    /// of the request itself. Against a 900-second token this costs at most
    /// one extra refresh per quarter hour.
    private static let expiryLeeway: TimeInterval = 60

    private let keychain: any AuthSessionStoring
    private let refresher: any TokenRefreshing
    private let session: AuthSession

    private var stored: StoredAuthSession?
    private var accessToken: String?
    private var accessTokenExpiresAt: Date?
    private var refreshTask: Task<RefreshedSession, Error>?
    private var hasReadKeychain = false

    init(
        keychain: any AuthSessionStoring,
        refresher: any TokenRefreshing,
        session: AuthSession
    ) {
        self.keychain = keychain
        self.refresher = refresher
        self.session = session
    }

    // MARK: - Launch

    /// One Keychain read. Returns the cached profile when there is a session
    /// to resume, so the Account tab can render immediately rather than
    /// waiting on a network round trip.
    func restore() -> AuthUser? {
        if !hasReadKeychain {
            stored = keychain.read()
            hasReadKeychain = true
        }

        return stored?.user.domainUser
    }

    // MARK: - AuthTokenProviding

    func accessToken() async throws -> String? {
        if let accessToken, isFresh {
            return accessToken
        }

        guard currentRefreshToken != nil else { return nil }

        return try await runRefresh().tokens.accessToken
    }

    func refreshedAccessToken(after staleToken: String?) async throws -> String? {
        // Somebody else refreshed while this caller was away getting its 401.
        // Returning the token they minted avoids spending a second rotation -
        // which, with a rotating refresh token, would end the session.
        if let accessToken, accessToken != staleToken, isFresh {
            return accessToken
        }

        guard currentRefreshToken != nil else { return nil }

        return try await runRefresh().tokens.accessToken
    }

    // MARK: - Writes

    func store(tokens: AuthTokens, user: AuthUser) async {
        let session = StoredAuthSession(
            refreshToken: tokens.refreshToken,
            user: StoredAuthUser(user),
            savedAt: Date()
        )

        // Persisted before being published in memory, so a crash in between
        // costs one re-sign-in rather than leaving a live session the next
        // launch cannot resume.
        persist(session)

        stored = session
        hasReadKeychain = true
        accessToken = tokens.accessToken
        accessTokenExpiresAt = Date().addingTimeInterval(TimeInterval(tokens.expiresIn))
    }

    func update(user: AuthUser) async {
        guard let stored else { return }

        let updated = StoredAuthSession(
            refreshToken: stored.refreshToken,
            user: StoredAuthUser(user),
            savedAt: Date()
        )

        persist(updated)
        self.stored = updated
    }

    /// The value `POST /auth/logout` needs in its body.
    func refreshToken() -> String? {
        if !hasReadKeychain {
            stored = keychain.read()
            hasReadKeychain = true
        }

        return stored?.refreshToken
    }

    /// Forgets everything. `notifying` publishes the sign-out to `AuthSession`;
    /// pass `false` where the caller is about to publish a *different* state
    /// itself, such as the sign-in chained onto a password reset.
    func clear(notifying: Bool) async {
        keychain.delete()

        stored = nil
        hasReadKeychain = true
        accessToken = nil
        accessTokenExpiresAt = nil
        refreshTask?.cancel()
        refreshTask = nil

        if notifying {
            await session.signedOut()
        }
    }
}

// MARK: - Private

private extension TokenStore {

    var isFresh: Bool {
        guard let accessTokenExpiresAt else { return false }

        return accessTokenExpiresAt.timeIntervalSinceNow > Self.expiryLeeway
    }

    var currentRefreshToken: String? {
        if !hasReadKeychain {
            stored = keychain.read()
            hasReadKeychain = true
        }

        return stored?.refreshToken
    }

    func runRefresh() async throws -> RefreshedSession {
        // Joining an in-flight refresh rather than starting a second one. This
        // read, and the assignment below, both happen before the first `await`
        // in this method, which is what makes actor re-entrancy harmless here.
        if let refreshTask {
            return try await refreshTask.value
        }

        guard let presented = currentRefreshToken else {
            throw AuthTokenError.signedOut
        }

        let refresher = refresher
        let task = Task { try await refresher.refresh(refreshToken: presented) }
        refreshTask = task

        defer { refreshTask = nil }

        do {
            let refreshed = try await task.value

            // The response carries the profile as well as the tokens, so a
            // refresh doubles as a free `GET /auth/me`.
            await store(tokens: refreshed.tokens, user: refreshed.user)

            return refreshed
        } catch let error as NetworkError {
            // Any 4xx from the refresh endpoint means the stored token is
            // dead: expired, already rotated, or revoked. 5xx, offline and
            // timeout must NEVER sign anybody out - a bad minute on the
            // backend would otherwise sign out every user at once.
            if let status = error.httpStatusCode, (400..<500).contains(status) {
                await clear(notifying: true)
            }

            throw error
        }
    }

    /// A failed Keychain write costs the user a re-sign-in on the next launch.
    /// That is not worth failing an otherwise successful sign-in over - but it
    /// is worth saying out loud, because the symptom (signed out again every
    /// launch) points nowhere near the cause.
    func persist(_ session: StoredAuthSession) {
        do {
            try keychain.write(session)
        } catch {
            Logger.authKeychain.error("Could not persist the session: \(error)")
        }
    }
}
