//
//  PadelFinderApp.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 30.05.26.
//

import SwiftUI
import PresentationLayer
import CoreDI
import CoreNetworking
import CoreSocialAuth
import DataLayer
import DomainLayer
import CoreFormatting

@main
struct PadelFinderApp: App {
    init() {
        // First, before anything can build a request. Evaluated here rather
        // than inside CoreNetworking because this is the only target where
        // DEBUG is reliably defined - package targets do not inherit the
        // project's compilation conditions.
        //
        // Local points at the dev server, where OTP_MAILER=log prints the
        // 6-digit codes straight to the console.
        #if DEBUG
        AppConfig.configure(environment: .local)
        #else
        AppConfig.configure(environment: .production)
        #endif

        // One call, not several: `AuthAssembly.loaded` kicks off session
        // restore and needs every other registration already in place, which
        // Swinject only guarantees within a single `apply`.
        AppDependency.shared.assemble([
            CoreNetworkingAssembly(),
            CoreFormatterAssembly(),
            DataAssembly(),
            DomainAssembly(),
            SocialAuthAssembly(),
            AuthAssembly()
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            PadelFinderTabView()
                // A provider's custom-scheme callback, forwarded through
                // CoreSocialAuth so the SDK stays inside that package.
                .onOpenURL { SocialAuthURLHandler.handle($0) }
        }
    }
}
