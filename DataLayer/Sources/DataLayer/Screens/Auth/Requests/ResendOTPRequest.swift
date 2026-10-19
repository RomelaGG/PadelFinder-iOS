//
//  ResendOTPRequest.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreNetworking

/// Sends another sign-up code. 202 even for an address with no pending
/// sign-up, in which case nothing is sent.
struct ResendOTPRequest: NetworkRequest {
    typealias Response = AcceptedResponseDTO

    let email: String

    var baseURLType: BaseURLType { .auth }
    var path: String { "/auth/otp/resend" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: BodyType { .object(EmailBody(email: email)) }
}
