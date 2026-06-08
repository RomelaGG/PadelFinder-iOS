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
        }
    }
}
