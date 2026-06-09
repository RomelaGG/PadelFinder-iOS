//
//  PadelCourtsTabFlowRunnerFactory.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI
import CoreNavigation
import DomainLayer

public struct PadelCourtsTabFlowView: View {
    @StateObject private var navigator = Navigator<PadelCourtsTabNavigatorDestination>()
    private let factory: PadelCourtsTabFlowRunnerFactory
    
    public init(fetchAvailabilityUseCase: any FetchAvailabilityUseCaseProtocol) {
        self.factory = PadelCourtsTabFlowRunnerFactory(
            fetchAvailabilityUseCase: fetchAvailabilityUseCase
        )
    }
    
    public var body: some View {
        factory.makeView(navigator: navigator)
    }
}
