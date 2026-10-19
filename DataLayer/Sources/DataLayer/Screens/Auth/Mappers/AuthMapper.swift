//
//  AuthMapper.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DomainLayer

protocol AuthMapperProtocol: Sendable {
    func mapUser(_ dto: UserResponseDTO) -> AuthUser
    func mapTokens(_ dto: TokenResponseDTO) -> AuthTokens
}

struct AuthMapper: AuthMapperProtocol {

    func mapUser(_ dto: UserResponseDTO) -> AuthUser {
        AuthUser(
            id: dto.id,
            email: dto.email,
            phone: dto.phone,
            displayName: dto.displayName,
            // An unrecognised provider is dropped rather than failing the
            // whole sign-in: a provider the server learns about before this
            // app does should not lock anybody out.
            providers: dto.providers.compactMap(AuthProvider.init(rawValue:))
        )
    }

    func mapTokens(_ dto: TokenResponseDTO) -> AuthTokens {
        AuthTokens(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: dto.expiresIn
        )
    }
}
