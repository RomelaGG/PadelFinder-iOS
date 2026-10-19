//
//  ResetPasswordRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

/// Spends a reset code and saves the new password.
///
/// Returns 204 with no tokens, and revokes every existing session - which is
/// why the repository signs the user back in afterwards.
struct ResetPasswordRequest: NetworkRequest {
    typealias Response = Empty

    let email: String
    let code: String
    let newPassword: String

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/password/reset" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType {
        .object(ResetPasswordBody(email: email, code: code, newPassword: newPassword))
    }
}
