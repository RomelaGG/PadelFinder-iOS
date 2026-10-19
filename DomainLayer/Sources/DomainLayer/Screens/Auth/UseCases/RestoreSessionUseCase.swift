//
//  RestoreSessionUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

/// Reads the saved session on launch.
///
/// Never throws and is safe to call twice: it is wired into app start-up,
/// where there is nobody to show an error to and nothing useful to do with one.
public protocol RestoreSessionUseCaseProtocol: Sendable {
    func execute() async
}

struct RestoreSessionUseCase: RestoreSessionUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute() async {
        await repository.restoreSession()
    }
}
