//
//  NetworkManager.swift
//  CoreServices
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import Alamofire
import Foundation

public final class NetworkManager: @unchecked Sendable {
    private let session: Session
    private let decoder: JSONDecoder
    private let errorMapper: AFErrorMapper

    public init(
        session: Session = .default,
        errorMapper: AFErrorMapper = AFErrorMapper()
    ) {
        self.session = session
        self.errorMapper = errorMapper
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func send<R: NetworkRequest>(_ request: R) async throws -> R.Response {
        guard let urlRequest = buildURLRequest(from: request) else {
            throw NetworkError.invalidRequest
        }

        do {
            return try await session
                .request(urlRequest)
                .validate()
                .serializingDecodable(R.Response.self, decoder: decoder)
                .value
        } catch let error as AFError {
            if error.isRequestCancellation {
                throw CancellationError()
            }

            throw errorMapper.map(error)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        }
    }
}

// MARK: - Private

private extension NetworkManager {

    func buildURLRequest<R: NetworkRequest>(from request: R) -> URLRequest? {
        guard var urlComponents = URLComponents(string: request.baseURLType.url + request.path) else {
            return nil
        }

        if let queryParams = request.queryParams {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else { return nil }

        var urlRequest = URLRequest(url: url)
        urlRequest.method = request.method
        urlRequest.timeoutInterval = request.timeoutInterval

        var headers = request.headers
        
        // TODO: Inject TokenManager and handle auth headers - [Network Package]
        if request.requiresAuth {
            // headers.add(.authorization(bearerToken: token))
        }
        
        headers.add(.contentType("application/json"))
        urlRequest.headers = headers

        switch request.body {
        case .object(let encodable):
            urlRequest.httpBody = try? JSONEncoder().encode(encodable)
        case .raw(let dict):
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: dict)
        case .empty:
            break
        }

        return urlRequest
    }
}

private extension AFError {
    var isRequestCancellation: Bool {
        if isExplicitlyCancelledError {
            return true
        }

        if case .sessionTaskFailed(let urlError as URLError) = self,
           urlError.code == .cancelled {
            return true
        }

        return false
    }
}
