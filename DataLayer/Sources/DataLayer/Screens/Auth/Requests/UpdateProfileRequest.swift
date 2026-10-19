//
//  UpdateProfileRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

/// Omitted fields are left untouched by the server, so `nil` means "leave as
/// it is" rather than "clear it".
struct UpdateProfileRequest: NetworkRequest {
    typealias Response = UserResponseDTO

    let displayName: String?
    let phone: String?

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/me" }
    var method: HTTPMethod { .patch }

    var body: BodyType {
        .object(UpdateProfileBody(displayName: displayName, phone: phone))
    }
}
