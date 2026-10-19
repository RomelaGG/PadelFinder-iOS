//
//  AuthAssembly.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI
import DomainLayer
import Swinject

public struct AuthAssembly: Assembly {

    public init() { }

    public func assemble(container: Container) {
        container.register(AuthPresenter.self) { _ in
            AuthPresenter()
        }
        .inObjectScope(.container)
    }

    /// `loaded` runs after every assembly has registered, so everything the
    /// restore path touches already exists. It is also the only hook that
    /// fires exactly once at start-up, which is what session restore wants:
    /// no view has to remember to kick it off, and no view can kick it off
    /// twice.
    public func loaded(resolver: Resolver) {
        guard let restoreSession = resolver.resolve(RestoreSessionUseCaseProtocol.self) else {
            return
        }

        Task { await restoreSession.execute() }
    }
}
