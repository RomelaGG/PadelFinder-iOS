//
//  LoginRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

struct LoginRequest: NetworkRequest {
    typealias Response = TokenResponseDTO

    let email: String
    let password: String

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/login" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType {
        .object(LoginBody(email: email, password: password))
    }
}
