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
    private let tokenProvider: (any AuthTokenProviding)?

    public init(
        session: Session = .default,
        errorMapper: AFErrorMapper = AFErrorMapper(),
        tokenProvider: (any AuthTokenProviding)? = nil
    ) {
        self.session = session
        self.errorMapper = errorMapper
        self.tokenProvider = tokenProvider
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    /// Sends a request, stamping the bearer token when the request asks for it.
    ///
    /// A 401 buys exactly one more attempt, after a refresh. That is a single
    /// `catch` branch rather than a loop on purpose: the retried attempt is
    /// never itself retried, so there is no recursion to bound.
    public func send<R: NetworkRequest>(_ request: R) async throws -> R.Response {
        let token = request.requiresAuth ? try await tokenProvider?.accessToken() : nil

        do {
            return try await perform(request, accessToken: token)
        } catch let error as NetworkError {
            guard request.requiresAuth,
                  error.httpStatusCode == 401,
                  let tokenProvider,
                  let refreshed = try await tokenProvider.refreshedAccessToken(after: token)
            else {
                throw error
            }

            return try await perform(request, accessToken: refreshed)
        }
    }

    /// Sends a request without a token and without the 401 retry.
    ///
    /// The refresh call itself uses this. Routing it through `send` would have
    /// the token provider re-enter itself while its own refresh is in flight -
    /// a permanent hang rather than a crash - so the refresh path is kept
    /// structurally unable to recurse, whatever `requiresAuth` happens to say.
    public func sendUnauthenticated<R: NetworkRequest>(_ request: R) async throws -> R.Response {
        try await perform(request, accessToken: nil)
    }
}

// MARK: - Private

private extension NetworkManager {

    func perform<R: NetworkRequest>(_ request: R, accessToken: String?) async throws -> R.Response {
        guard let urlRequest = try buildURLRequest(from: request, accessToken: accessToken) else {
            throw NetworkError.invalidRequest
        }

        // `.response` rather than `.value`: the error body is where the backend
        // explains the refusal, and `.value` throws it away.
        let response = await session
            .request(urlRequest)
            .validate()
            .serializingDecodable(R.Response.self, decoder: decoder)
            .response

        switch response.result {
        case .success(let value):
            return value

        case .failure(let error):
            if error.isRequestCancellation {
                throw CancellationError()
            }

            if case .sessionTaskFailed(let urlError as URLError) = error,
               urlError.code == .cancelled {
                throw CancellationError()
            }

            throw errorMapper.map(
                error,
                body: response.data,
                statusCode: response.response?.statusCode
            )
        }
    }

    func buildURLRequest<R: NetworkRequest>(
        from request: R,
        accessToken: String?
    ) throws -> URLRequest? {
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

        if let accessToken {
            headers.add(.authorization(bearerToken: accessToken))
        }

        headers.add(.contentType("application/json"))
        urlRequest.headers = headers

        switch request.body {
        case .object(let encodable):
            // Thrown rather than swallowed: an unencodable body would otherwise
            // be sent as no body at all and come back as a baffling validation
            // error from the server.
            urlRequest.httpBody = try JSONEncoder().encode(encodable)
        case .raw(let dict):
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: dict)
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
