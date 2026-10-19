//
//  TokenRefresher.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI
import DomainLayer

struct RefreshedSession: Sendable {
    let tokens: AuthTokens
    let user: AuthUser
}

protocol TokenRefreshing: Sendable {
    func refresh(refreshToken: String) async throws -> RefreshedSession
}

/// Sits between the token store and the network so the store deals only in
/// domain types and never has to know about DTOs.
struct TokenRefresher: TokenRefreshing {
    @Injected private var dataSource: any AuthRefreshRemoteDataSourceProtocol
    @Injected private var mapper: any AuthMapperProtocol

    func refresh(refreshToken: String) async throws -> RefreshedSession {
        let dto = try await dataSource.refresh(refreshToken: refreshToken)

        return RefreshedSession(
            tokens: mapper.mapTokens(dto),
            user: mapper.mapUser(dto.user)
        )
    }
}
