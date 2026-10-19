//
//  NetworkRequest.swift
//  CoreServices
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import Alamofire
import Foundation

// MARK: - Supporting Types

/// Where the app points.
///
/// The environment is chosen in the app target - the only place `DEBUG` is
/// reliably defined - and pushed down here with `configure(environment:)`.
/// Nothing in this package branches on a build configuration, so no package
/// manifest or project setting has to know about environments.
public enum AppConfig {

    public enum Environment: String, Sendable {
        case local
        case production

        var host: String {
            switch self {
            case .local:      return "http://127.0.0.1:8080"
            case .production: return "https://padelfinder-ge.fly.dev"
            }
        }
    }

    /// Written exactly once, from `PadelFinderApp.init`, before any request is
    /// built. Reads happen on whatever thread a request is built on, which is
    /// why this is `nonisolated(unsafe)` rather than actor-isolated: making it
    /// `@MainActor` would force every request construction onto the main actor.
    nonisolated(unsafe) private static var environment: Environment = .production

    /// Call first in `PadelFinderApp.init`.
    public static func configure(environment: Environment) {
        Self.environment = environment
    }

    public static var currentEnvironment: Environment { environment }

    /// Resolution order, most specific first:
    ///
    /// 1. `PF_API_HOST` in the process environment - set per scheme, so a Debug
    ///    build on a real device can point at the Mac's LAN address and UI
    ///    tests can point at a stub, with no code change.
    /// 2. `PFAPIHost` in Info.plist - the door xcconfig files will come through
    ///    when environments get their own build configurations. Absent today.
    /// 3. The configured environment, defaulting to production so a Release
    ///    build that forgets to configure still fails safe.
    private static var host: String {
        if let override = ProcessInfo.processInfo.environment["PF_API_HOST"],
           !override.isEmpty {
            return override
        }

        if let plistHost = Bundle.main.object(forInfoDictionaryKey: "PFAPIHost") as? String,
           !plistHost.isEmpty {
            return plistHost
        }

        return environment.host
    }

    public static var baseURL: String { host }
    public static var authURL: String { host }
    public static var cdnURL: String { host }
}

public enum BaseURLType {
    case `default`
    case auth
    case cdn

    public var url: String {
        switch self {
        case .default: return AppConfig.baseURL
        case .auth:    return AppConfig.authURL
        case .cdn:     return AppConfig.cdnURL
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
