//
//  CompanyAvailabilityRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 17.06.26.
//

import Alamofire
import CoreNetworking

struct CompanyAvailabilityRequest: NetworkRequest {
    typealias Response = CompanyAvailabilityResponseDTO

    let companyId: String
    let date: String

    var path: String { "/availability/company/\(companyId)" }
    var method: HTTPMethod { .get }
    var queryParams: [String: String]? { ["date": date] }
    var requiresAuth: Bool { false }
}
