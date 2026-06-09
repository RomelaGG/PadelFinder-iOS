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
    }
}
