//
//  NetworkRequest.swift
//  CoreServices
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import Alamofire
import Foundation

// MARK: - Supporting Types

public enum BaseURLType {
    case `default`
    case auth
    case cdn

    public var url: String {
        switch self {
        case .default: return "AppConfig.baseURL"
        case .auth:    return "AppConfig.authURL"
        case .cdn:     return "AppConfig.cdnURL"
        }
    }
}

public enum BodyType {
    case object(Encodable)
    case raw([String: Any])
    case empty
}

// MARK: - Protocol

public protocol NetworkRequest {
    associatedtype Response: Decodable & Sendable

    var baseURLType: BaseURLType { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var body: BodyType { get }
    var queryParams: [String: String]? { get }
    var requiresAuth: Bool { get }
    var timeoutInterval: TimeInterval { get }
}

// MARK: - Default values via Protocol Extension

public extension NetworkRequest {
    var baseURLType: BaseURLType       { .default }
    var method: HTTPMethod             { .post }
    var headers: HTTPHeaders           { [] }
    var body: BodyType                 { .empty }
    var queryParams: [String: String]? { nil }
    var requiresAuth: Bool             { true }
    var timeoutInterval: TimeInterval  { 30 }
}
