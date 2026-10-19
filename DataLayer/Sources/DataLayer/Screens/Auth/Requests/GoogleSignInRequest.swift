//
//  GoogleSignInRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

struct GoogleSignInRequest: NetworkRequest {
    typealias Response = TokenResponseDTO

    let identityToken: String
    let nonce: String?

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/google" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType {
        .object(GoogleSignInBody(identityToken: identityToken, nonce: nonce))
    }
}
