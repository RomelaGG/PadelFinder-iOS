//
//  CoreServicesAssembly.swift
//  CoreServices
//
//  Created by Giorgi Romelashvili on 08.06.26.
//

import Swinject

public struct CoreServicesAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        container.register(NetworkManager.self) { _ in
            NetworkManager(errorMapper: AFErrorMapper())
        }.inObjectScope(.container)
    }
}
