//
//  DataAssembly.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import DomainLayer
import PadelFinderCoreServices
import Swinject

public struct DataAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(AvailabilityRemoteDataSourceProtocol.self) { resolver in
            guard let networkManager = resolver.resolve(NetworkManager.self) else {
                fatalError("Could not resolve dependency: \(NetworkManager.self)")
            }

            return AvailabilityRemoteDataSource(networkManager: networkManager)
        }
        .inObjectScope(.container)

        container.register(AvailabilityRepositoryProtocol.self) { resolver in
            guard let remoteDataSource = resolver.resolve(AvailabilityRemoteDataSourceProtocol.self) else {
                fatalError("Could not resolve dependency: \(AvailabilityRemoteDataSourceProtocol.self)")
            }

            return AvailabilityRepository(remoteDataSource: remoteDataSource)
        }
        .inObjectScope(.container)

        container.register(FetchAvailabilityUseCaseProtocol.self) { resolver in
            guard let repository = resolver.resolve(AvailabilityRepositoryProtocol.self) else {
                fatalError("Could not resolve dependency: \(AvailabilityRepositoryProtocol.self)")
            }

            return FetchAvailabilityUseCase(repository: repository)
        }
        .inObjectScope(.container)
    }
}
