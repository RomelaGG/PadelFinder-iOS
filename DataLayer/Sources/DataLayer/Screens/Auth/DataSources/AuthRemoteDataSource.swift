//
//  AuthRemoteDataSource.swift
//  DataLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import Alamofire
import CoreDI
import CoreNetworking

protocol AuthRemoteDataSourceProtocol: Sendable {
    func register(email: String, password: String, displayName: String?) async throws -> AcceptedResponseDTO
    func verifyOTP(email: String, code: String) async throws -> TokenResponseDTO
    func resendOTP(email: String) async throws -> AcceptedResponseDTO
    func login(email: String, password: String) async throws -> TokenResponseDTO
    func signInWithApple(identityToken: String, nonce: String?, displayName: String?) async throws -> TokenResponseDTO
    func signInWithGoogle(identityToken: String, nonce: String?) async throws -> TokenResponseDTO
    func logout(refreshToken: String) async throws
    func forgotPassword(email: String) async throws -> AcceptedResponseDTO
    func resetPassword(email: String, code: String, newPassword: String) async throws
    func currentUser() async throws -> UserResponseDTO
    func updateProfile(displayName: String?, phone: String?) async throws -> UserResponseDTO
    func deleteAccount() async throws
}

final class AuthRemoteDataSource: AuthRemoteDataSourceProtocol, @unchecked Sendable {
    @Injected private var networkManager: NetworkManager

    func register(
        email: String,
        password: String,
        displayName: String?
    ) async throws -> AcceptedResponseDTO {
        try await networkManager.send(
            RegisterRequest(email: email, password: password, displayName: displayName)
        )
    }

    func verifyOTP(email: String, code: String) async throws -> TokenResponseDTO {
        try await networkManager.send(VerifyOTPRequest(email: email, code: code))
    }

    func resendOTP(email: String) async throws -> AcceptedResponseDTO {
        try await networkManager.send(ResendOTPRequest(email: email))
    }

    func login(email: String, password: String) async throws -> TokenResponseDTO {
        try await networkManager.send(LoginRequest(email: email, password: password))
    }

    func signInWithApple(
        identityToken: String,
        nonce: String?,
        displayName: String?
    ) async throws -> TokenResponseDTO {
        try await networkManager.send(
            AppleSignInRequest(
                identityToken: identityToken,
                nonce: nonce,
                displayName: displayName
            )
        )
    }

    func signInWithGoogle(identityToken: String, nonce: String?) async throws -> TokenResponseDTO {
        try await networkManager.send(
            GoogleSignInRequest(identityToken: identityToken, nonce: nonce)
        )
    }

    func logout(refreshToken: String) async throws {
        _ = try await networkManager.send(LogoutRequest(refreshToken: refreshToken))
    }

    func forgotPassword(email: String) async throws -> AcceptedResponseDTO {
        try await networkManager.send(ForgotPasswordRequest(email: email))
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        _ = try await networkManager.send(
            ResetPasswordRequest(email: email, code: code, newPassword: newPassword)
        )
    }

    func currentUser() async throws -> UserResponseDTO {
        try await networkManager.send(CurrentUserRequest())
    }

    func updateProfile(displayName: String?, phone: String?) async throws -> UserResponseDTO {
        try await networkManager.send(
            UpdateProfileRequest(displayName: displayName, phone: phone)
        )
    }

    func deleteAccount() async throws {
        _ = try await networkManager.send(DeleteAccountRequest())
    }
}
