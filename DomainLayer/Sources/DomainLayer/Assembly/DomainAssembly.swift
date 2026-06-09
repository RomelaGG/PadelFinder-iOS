//
//  DomainAssembly.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 09.06.26.
//

import Swinject

public struct DomainAssembly: Assembly {
    public init() { }
    
    public func assemble(container: Swinject.Container) {
        container.register(FetchAvailabilityUseCaseProtocol.self) { _ in
            FetchAvailabilityUseCase()
        }
        .inObjectScope(.container)
    }
}
