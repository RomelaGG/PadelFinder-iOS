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
        container.register(NetworkManager.self) { resolver in
            // Resolved optionally so this package still works on its own: with
            // no token provider registered, every request goes out
            // unauthenticated, which is exactly how the app behaved before
            // accounts existed. Safe to resolve here whatever the assembly
            // order is, because Swinject runs every `assemble` before any
            // factory is called.
            NetworkManager(
                errorMapper: AFErrorMapper(),
                tokenProvider: resolver.resolve((any AuthTokenProviding).self)
            )
        }.inObjectScope(.container)
    }
}
