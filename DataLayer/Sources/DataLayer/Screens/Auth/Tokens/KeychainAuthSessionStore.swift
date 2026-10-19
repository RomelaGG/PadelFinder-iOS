//
//  KeychainAuthSessionStore.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Foundation
import OSLog
import Security

protocol AuthSessionStoring: Sendable {
    /// Never throws. A missing or corrupt item means "not signed in", and a
    /// damaged Keychain entry must not be able to stop the app launching.
    func read() -> StoredAuthSession?
    func write(_ session: StoredAuthSession) throws
    func delete()
}

enum KeychainError: Error {
    case writeFailed(OSStatus)
}

extension Logger {
    /// Keychain failures are invisible by nature - the user simply finds
    /// themselves signed out next launch with nothing to go on. Worth a log.
    static let authKeychain = Logger(subsystem: "GR.PadelFinder", category: "auth.keychain")
}

/// The refresh token's home.
///
/// `kSecAttrAccessibleAfterFirstUnlock` so a background refresh works while
/// the phone is locked, and `kSecAttrSynchronizable` false so a long-lived
/// credential never leaves the device through iCloud.
struct KeychainAuthSessionStore: AuthSessionStoring {
    private let service: String
    private let account: String

    init(
        service: String = "GR.PadelFinder.auth",
        account: String = "session"
    ) {
        self.service = service
        self.account = account
    }

    func read() -> StoredAuthSession? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else { return nil }

        guard status == errSecSuccess, let data = item as? Data else {
            Logger.authKeychain.error("Keychain read failed (OSStatus \(status))")
            return nil
        }

        return try? JSONDecoder().decode(StoredAuthSession.self, from: data)
    }

    func write(_ session: StoredAuthSession) throws {
        let data = try JSONEncoder().encode(session)

        // Update first, add only if there is nothing to update. The reverse
        // order - delete then add - leaves the user signed out if the process
        // dies in between.
        let updateStatus = SecItemUpdate(
            baseQuery as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )

        if updateStatus == errSecSuccess { return }

        guard updateStatus == errSecItemNotFound else {
            throw KeychainError.writeFailed(updateStatus)
        }

        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        // Only settable at insert time, which is fine: it is set once and
        // never needs changing.
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let addStatus = SecItemAdd(attributes as CFDictionary, nil)

        guard addStatus == errSecSuccess else {
            throw KeychainError.writeFailed(addStatus)
        }
    }

    func delete() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any
        ]
    }
}
