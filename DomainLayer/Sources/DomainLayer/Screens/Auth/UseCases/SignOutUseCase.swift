//
//  SignOutUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

/// Signs out. Cannot fail.
///
/// The server call is a courtesy - it revokes the refresh token family - but
/// the device is signed out either way. A user who taps Sign out and stays
/// signed in because the network was down would rightly not trust the button.
public protocol SignOutUseCaseProtocol: Sendable {
    func execute() async
}

struct SignOutUseCase: SignOutUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute() async {
        await repository.signOut()
    }
}
