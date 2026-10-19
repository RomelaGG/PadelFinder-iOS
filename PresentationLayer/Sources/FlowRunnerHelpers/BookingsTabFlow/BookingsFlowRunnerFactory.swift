//
//  BookingsFlowRunnerFactory.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import SwiftUI

@MainActor
struct BookingsFlowRunnerFactory {
    func makeView(navigator: Navigator<BookingsNavigatorDestination>) -> some View {
        NavigationHost(navigator: navigator) {
            BookingsView(viewModel: .init(state: .init()))
        }
    }
}
