//
//  AuthFlowRunnerFactory.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import SwiftUI

@MainActor
struct AuthFlowRunnerFactory {
    func makeView(navigator: Navigator<AuthNavigatorDestination>) -> some View {
        NavigationHost(navigator: navigator) {
            WelcomeView()
        }
    }
}
