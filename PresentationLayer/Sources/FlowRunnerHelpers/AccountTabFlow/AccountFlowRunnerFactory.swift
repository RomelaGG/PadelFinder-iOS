//
//  AccountFlowRunnerFactory.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import SwiftUI

@MainActor
struct AccountFlowRunnerFactory {
    func makeView(navigator: Navigator<AccountNavigatorDestination>) -> some View {
        NavigationHost(navigator: navigator) {
            AccountView(viewModel: .init(state: .init()))
        }
    }
}
