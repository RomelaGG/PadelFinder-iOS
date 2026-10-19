//
//  AuthRefreshRemoteDataSource.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI
import CoreNetworking

/// Separate from `AuthRemoteDataSource` for one reason: this is the only call
/// that must bypass the token-stamping and 401-retry path, and keeping it in
/// its own type makes that impossible to forget.
protocol AuthRefreshRemoteDataSourceProtocol: Sendable {
    func refresh(refreshToken: String) async throws -> TokenResponseDTO
}

final class AuthRefreshRemoteDataSource: AuthRefreshRemoteDataSourceProtocol, @unchecked Sendable {
    @Injected private var networkManager: NetworkManager

    func refresh(refreshToken: String) async throws -> TokenResponseDTO {
        try await networkManager.sendUnauthenticated(
            RefreshTokenRequest(refreshToken: refreshToken)
        )
    }
}
