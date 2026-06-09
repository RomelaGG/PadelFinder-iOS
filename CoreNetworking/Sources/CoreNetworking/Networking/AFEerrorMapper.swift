//
//  AFErrorMapper.swift
//  CoreServices
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import Alamofire
import Foundation

public final class AFErrorMapper {

    public init() {}

    public func map(_ error: AFError) -> NetworkError {
        switch error {
        case .responseValidationFailed(let reason):
            return mapValidationError(reason: reason, originalError: error)

        case .sessionTaskFailed(let urlError as URLError):
            return mapURLError(urlError)

        case .responseSerializationFailed:
            return .decodingFailed

        default:
            return .unknown(error)
        }
    }
}

// MARK: - Private

private extension AFErrorMapper {

    func mapValidationError(
        reason: AFError.ResponseValidationFailureReason,
        originalError: AFError
    ) -> NetworkError {
        guard case .unacceptableStatusCode(let code) = reason else {
            return .unknown(originalError)
        }
        switch code {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 500...: return .serverError(code)
        default:     return .unknown(originalError)
        }
    }

    func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet,
             .networkConnectionLost:
            return .noInternet
        case .timedOut:
            return .timeout
        default:
            return .unknown(error)
        }
    }
}
