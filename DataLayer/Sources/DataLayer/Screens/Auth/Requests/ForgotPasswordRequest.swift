//
//  ForgotPasswordRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

/// Asks for a reset code. Always 202, including for addresses with no account.
struct ForgotPasswordRequest: NetworkRequest {
    typealias Response = AcceptedResponseDTO

    let email: String

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/password/forgot" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType { .object(EmailBody(email: email)) }
}
