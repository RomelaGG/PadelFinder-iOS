//
//  DeleteAccountRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

struct DeleteAccountRequest: NetworkRequest {
    typealias Response = Empty

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/me" }
    var method: HTTPMethod { .delete }
}
