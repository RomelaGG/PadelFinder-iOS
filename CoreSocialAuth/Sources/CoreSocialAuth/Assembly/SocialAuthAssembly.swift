//
//  SocialAuthAssembly.swift
//  CoreSocialAuth
//
//  Created by Giorgi Romelashvili on 21.10.26.
//

import DomainLayer
import Swinject

/// Registers the device-side half of social sign-in.
///
/// One line, and it is the only line that knows *how* a Google `id_token` is
/// obtained. Swapping the SDK for a hand-rolled `ASWebAuthenticationSession`
/// + PKCE flow is a change to this registration and nothing else.
public struct SocialAuthAssembly: Assembly {

    public init() { }

    public func assemble(container: Container) {
        container.register((any GoogleCredentialProviding).self) { _ in
            GoogleSignInCredentialProvider()
        }
        .inObjectScope(.container)
    }
}
