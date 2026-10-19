//
//  AuthValidation.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

/// Client-side checks, kept deliberately shallow.
///
/// The real validators are the server and whether the code actually arrives in
/// somebody's inbox. A clever regex here would only ever reject addresses that
/// turn out to work.
enum AuthValidation {

    /// Non-empty, has an `@`, and at least one `.` after it.
    static func isPlausibleEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let atIndex = trimmed.firstIndex(of: "@"), atIndex != trimmed.startIndex else {
            return false
        }

        let domain = trimmed[trimmed.index(after: atIndex)...]

        guard let dotIndex = domain.firstIndex(of: "."), dotIndex != domain.startIndex else {
            return false
        }

        return dotIndex < domain.index(before: domain.endIndex)
    }

    /// Emails are normalised on the way through the view model so the server
    /// sees the same thing the user will type next time.
    static func normalizeEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Server caps `displayName` at 120 characters.
    static func normalizeNickname(_ nickname: String) -> String? {
        let trimmed = String(nickname.trimmingCharacters(in: .whitespacesAndNewlines).prefix(120))

        return trimmed.isEmpty ? nil : trimmed
    }
}
