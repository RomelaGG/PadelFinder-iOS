//
//  PadelFlowRunnerFactory.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI
import CoreNavigation
import DomainLayer

struct PadelCourtsTabFlowRunnerFactory {
    private let fetchAvailabilityUseCase: any FetchAvailabilityUseCaseProtocol

    init(fetchAvailabilityUseCase: any FetchAvailabilityUseCaseProtocol) {
        self.fetchAvailabilityUseCase = fetchAvailabilityUseCase
    }

    func makeView(navigator: Navigator<PadelCourtsTabNavigatorDestination>) -> some View {
        NavigationHost(navigator: navigator) {
            PadelCompaniesView(
                viewModel: .init(
                    state: .init(),
                    fetchAvailabilityUseCase: fetchAvailabilityUseCase
                )
            )
        }
    }
}
