//
//  VerifyOTPRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

/// Spends a sign-up code and, on success, returns the first token pair.
struct VerifyOTPRequest: NetworkRequest {
    typealias Response = TokenResponseDTO

    let email: String
    let code: String

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/otp/verify" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType {
        .object(VerifyCodeBody(email: email, code: code))
    }
}
