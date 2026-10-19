//
//  NetworkError.swift
//  CoreServices
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import Foundation

public enum NetworkError: LocalizedError {

    case invalidRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case decodingFailed
    case noInternet
    case timeout
    case unknown(Error)

    /// A refusal the backend described in its own words. Carries the stable
    /// `code` the caller switches on and the sentence it may show.
    case apiError(APIError)

    /// Status that produced this error, where there was one. Used to decide
    /// whether a request is worth retrying after a token refresh.
    public var httpStatusCode: Int? {
        switch self {
        case .apiError(let error):   return error.statusCode
        case .unauthorized:          return 401
        case .forbidden:             return 403
        case .notFound:              return 404
        case .serverError(let code): return code
        default:                     return nil
        }
    }

    public var errorDescription: String? {
        switch self {
        case .invalidRequest:        return "Invalid request."
        case .unauthorized:          return "Unauthorized. Please log in again."
        case .forbidden:             return "You don't have permission to perform this action."
        case .notFound:              return "Resource not found."
        case .serverError(let code): return "Server error: \(code). Please try again later."
        case .decodingFailed:        return "Failed to parse response."
        case .noInternet:            return "No internet connection."
        case .timeout:               return "Request timed out. Please try again."
        case .unknown(let error):    return error.localizedDescription

        case .apiError(let error):
            // Only a coded refusal is written for a user to read. Without a
            // code the text is Vapor's own prose, so fall back to the sentence
            // this status produced before envelopes were decoded at all -
            // which keeps every existing screen's message byte-identical.
            guard error.isActionable else {
                return NetworkError.statusFallback(error.statusCode).errorDescription
            }

            return error.reason
        }
    }

    private static func statusFallback(_ statusCode: Int) -> NetworkError {
        switch statusCode {
        case 401:    return .unauthorized
        case 403:    return .forbidden
        case 404:    return .notFound
        case 500...: return .serverError(statusCode)
        default:     return .invalidRequest
        }
    }
}
