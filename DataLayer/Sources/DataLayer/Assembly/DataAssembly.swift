//
//  DataAssembly.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import DomainLayer
import Swinject

public struct DataAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(AvailabilityRemoteDataSourceProtocol.self) { _ in
            AvailabilityRemoteDataSource()
        }
        .inObjectScope(.container)

        container.register(AvailabilityRepositoryProtocol.self) { resolver in
            guard let remoteDataSource = resolver.resolve(AvailabilityRemoteDataSourceProtocol.self) else {
                fatalError("Could not resolve dependency: \(AvailabilityRemoteDataSourceProtocol.self)")
            }

            return AvailabilityRepository(remoteDataSource: remoteDataSource)
        }
        .inObjectScope(.container)
    }
}
