//
//  CoreNetworkingAssembly.swift
//  CoreNetworking
//
//  Created by Giorgi Romelashvili on 09.06.26.
//

import Swinject

public struct CoreNetworkingAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        container.register(NetworkManager.self) { _ in
            NetworkManager(errorMapper: AFErrorMapper())
        }.inObjectScope(.container)
    }
}

