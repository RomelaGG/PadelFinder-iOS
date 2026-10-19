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

        container.register(FetchCompanyAvailabilityUseCaseProtocol.self) { _ in
            FetchCompanyAvailabilityUseCase()
        }
        .inObjectScope(.container)

        assembleAuth(container: container)
    }
}

// MARK: - Auth

private extension DomainAssembly {

    /// `AuthSession` is registered here, not in the presentation layer's
    /// `AuthAssembly`, because the module that declares a type owns its
    /// registration. The token store in `DataLayer` resolves this to sign a
    /// user out when a refresh comes back revoked, and it must not need the
    /// presentation layer to be present to do that.
    func assembleAuth(container: Container) {
        container.register(AuthSession.self) { _ in
            AuthSession()
        }
        .inObjectScope(.container)

        container.register(RegisterUseCaseProtocol.self) { _ in
            RegisterUseCase()
        }
        .inObjectScope(.container)

        container.register(VerifyEmailCodeUseCaseProtocol.self) { _ in
            VerifyEmailCodeUseCase()
        }
        .inObjectScope(.container)

        container.register(ResendCodeUseCaseProtocol.self) { _ in
            ResendCodeUseCase()
        }
        .inObjectScope(.container)

        container.register(SignInUseCaseProtocol.self) { _ in
            SignInUseCase()
        }
        .inObjectScope(.container)

        container.register(SignInWithAppleUseCaseProtocol.self) { _ in
            SignInWithAppleUseCase()
        }
        .inObjectScope(.container)

        container.register(SignInWithGoogleUseCaseProtocol.self) { _ in
            SignInWithGoogleUseCase()
        }
        .inObjectScope(.container)

        container.register(RequestPasswordResetUseCaseProtocol.self) { _ in
            RequestPasswordResetUseCase()
        }
        .inObjectScope(.container)

        container.register(ResetPasswordUseCaseProtocol.self) { _ in
            ResetPasswordUseCase()
        }
        .inObjectScope(.container)

        container.register(SignOutUseCaseProtocol.self) { _ in
            SignOutUseCase()
        }
        .inObjectScope(.container)

        container.register(DeleteAccountUseCaseProtocol.self) { _ in
            DeleteAccountUseCase()
        }
        .inObjectScope(.container)

        container.register(RestoreSessionUseCaseProtocol.self) { _ in
            RestoreSessionUseCase()
        }
        .inObjectScope(.container)

        container.register(FetchCurrentUserUseCaseProtocol.self) { _ in
            FetchCurrentUserUseCase()
        }
        .inObjectScope(.container)

        container.register(UpdateProfileUseCaseProtocol.self) { _ in
            UpdateProfileUseCase()
        }
        .inObjectScope(.container)
    }
}
