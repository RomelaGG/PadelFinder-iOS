//
//  AppleSignInRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

struct AppleSignInRequest: NetworkRequest {
    typealias Response = TokenResponseDTO

    let identityToken: String
    let nonce: String?
    let displayName: String?

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/apple" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType {
        .object(
            AppleSignInBody(
                identityToken: identityToken,
                nonce: nonce,
                displayName: displayName
            )
        )
    }
}
