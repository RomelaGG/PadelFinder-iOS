//
//  DataAssembly.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import CoreNetworking
import DomainLayer
import Swinject

public struct DataAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(AvailabilityMapperProtocol.self) { _ in
            AvailabilityMapper()
        }
        .inObjectScope(.container)

        container.register(AvailabilityRemoteDataSourceProtocol.self) { _ in
            AvailabilityRemoteDataSource()
        }
        .inObjectScope(.container)

        container.register(AvailabilityRepositoryProtocol.self) { _ in
            AvailabilityRepository()
        }
        .inObjectScope(.container)

        assembleAuth(container: container)
    }
}

// MARK: - Auth

private extension DataAssembly {

    func assembleAuth(container: Container) {
        container.register(AuthMapperProtocol.self) { _ in
            AuthMapper()
        }
        .inObjectScope(.container)

        container.register(AuthErrorMapperProtocol.self) { _ in
            AuthErrorMapper()
        }
        .inObjectScope(.container)

        container.register(AuthSessionStoring.self) { _ in
            KeychainAuthSessionStore()
        }
        .inObjectScope(.container)

        container.register(AuthRemoteDataSourceProtocol.self) { _ in
            AuthRemoteDataSource()
        }
        .inObjectScope(.container)

        container.register(AuthRefreshRemoteDataSourceProtocol.self) { _ in
            AuthRefreshRemoteDataSource()
        }
        .inObjectScope(.container)

        container.register(TokenRefreshing.self) { _ in
            TokenRefresher()
        }
        .inObjectScope(.container)

        // The only type here built with constructor injection rather than
        // `@Injected`. It is an actor, and resolving its collaborators lazily
        // from inside actor-isolated code would mean every access hopping
        // through the container.
        //
        // `implements` forwards the same registration - and therefore the same
        // instance - to `AuthTokenProviding`, which is what `NetworkManager`
        // resolves. One token owner, reached from both sides.
        container.register(TokenStore.self) { resolver in
            TokenStore(
                keychain: resolver.resolve(AuthSessionStoring.self)!,
                refresher: resolver.resolve(TokenRefreshing.self)!,
                session: resolver.resolve(AuthSession.self)!
            )
        }
        .implements((any AuthTokenProviding).self)
        .inObjectScope(.container)

        container.register(AuthRepositoryProtocol.self) { _ in
            AuthRepository()
        }
        .inObjectScope(.container)
    }
}
