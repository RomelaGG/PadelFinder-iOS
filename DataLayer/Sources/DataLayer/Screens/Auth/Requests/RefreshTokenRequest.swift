//
//  RefreshTokenRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

/// Trades a refresh token for a new pair.
///
/// `requiresAuth` is false and this is sent through
/// `NetworkManager.sendUnauthenticated`: the token goes in the body, and
/// routing it through the authenticated path would have the token store wait
/// on its own in-flight refresh.
struct RefreshTokenRequest: NetworkRequest {
    typealias Response = TokenResponseDTO

    let refreshToken: String

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/refresh" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType { .object(RefreshBody(refreshToken: refreshToken)) }
}
