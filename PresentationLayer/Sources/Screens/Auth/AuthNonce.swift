//
//  AuthNonce.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 21.10.26.
//

import Security

/// The one-time value that ties an identity token to the request that asked
/// for it.
///
/// Both providers echo the `nonce` claim back **verbatim**, and the server
/// compares it verbatim too (`AppleIdentityTokenVerifier`,
/// `GoogleIdentityTokenVerifier`). So the value set on the authorization
/// request is the value sent in the request body - no hashing. The Firebase
/// pattern of `request.nonce = sha256(raw)` plus sending `raw` exists because
/// *Firebase's* backend hashes before comparing; against a verbatim
/// comparison it would simply make the two sides disagree.
///
/// Hex rather than base64url because the same value goes into Google's
/// authorization URL as a query parameter, and hex needs no escaping.
///
/// Two limitations worth knowing, both deliberate:
///
/// 1. The server stores no nonce it issued, so the comparison proves only
///    that the token's `nonce` claim equals a value the *same client* sent in
///    the *same* request body. Replaying the whole `{identityToken, nonce}`
///    pair passes it. What actually limits replay today is TLS plus the `exp`
///    claim, which both verifiers already enforce. Real protection needs a
///    server-issued single-use nonce (`POST /auth/nonce` -> persist ->
///    consume on use), and the API has no such endpoint.
/// 2. `nonce` is optional on both endpoints, and both verifiers skip the
///    check entirely when it is absent. That is intentional for Apple, whose
///    older platforms did not echo it back; for Google it is a gap worth
///    closing on the server once this client always sends one.
enum AuthNonce {

    /// 32 bytes from the system CSPRNG, hex-encoded.
    ///
    /// `SecRandomCopyBytes` can fail, and silently falling back to anything
    /// weaker would be worse than the alternative: a nonce the provider then
    /// refuses to echo, which surfaces as a sign-in that does not work rather
    /// than one that looks like it worked.
    static func make() -> String? {
        var bytes = [UInt8](repeating: 0, count: 32)

        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
            return nil
        }

        return bytes.map { String(format: "%02x", $0) }.joined()
    }
}
