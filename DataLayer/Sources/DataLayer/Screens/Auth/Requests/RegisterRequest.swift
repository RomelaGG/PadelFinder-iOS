//
//  RegisterRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

/// Starts email sign-up. Answers 202 whether or not the address is already
/// taken, so nothing about the response reveals who has an account.
struct RegisterRequest: NetworkRequest {
    typealias Response = AcceptedResponseDTO

    let email: String
    let password: String
    let displayName: String?

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/register" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType {
        .object(RegisterBody(email: email, password: password, displayName: displayName))
    }
}
