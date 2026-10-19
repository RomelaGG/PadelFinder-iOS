//
//  CurrentUserRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

struct CurrentUserRequest: NetworkRequest {
    typealias Response = UserResponseDTO

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/me" }
    var method: HTTPMethod { .get }
}
