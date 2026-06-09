//
//  AvailabilityRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import Alamofire
import PadelFinderCoreServices

struct AvailabilityRequest: NetworkRequest {
    typealias Response = AvailabilityResponseDTO

    let date: String

    var path: String { "/availability" }
    var method: HTTPMethod { .get }
    var queryParams: [String: String]? { ["date": date] }
    var requiresAuth: Bool { false }
}
