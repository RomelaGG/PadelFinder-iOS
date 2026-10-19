//
//  LogoutRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

/// Revokes one device's token family. 204, and 204 even for a token the
/// server has never seen.
struct LogoutRequest: NetworkRequest {
    typealias Response = Empty

    let refreshToken: String

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/logout" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType { .object(RefreshBody(refreshToken: refreshToken)) }
}
