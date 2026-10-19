//
//  ResendCodeUseCase.swift
//  DomainLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI

/// One button, two endpoints.
///
/// The code screen has a single Resend action and should not have to know that
/// the server files sign-up codes and reset codes under different purposes.
public protocol ResendCodeUseCaseProtocol: Sendable {
    func execute(email: String, purpose: OTPPurpose) async throws
}

struct ResendCodeUseCase: ResendCodeUseCaseProtocol {
    @Injected private var repository: any AuthRepositoryProtocol

    func execute(email: String, purpose: OTPPurpose) async throws {
        try await repository.resendCode(email: email, purpose: purpose)
    }
}
