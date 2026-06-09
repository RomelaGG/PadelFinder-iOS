//
//  PadelFinderApp.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 30.05.26.
//

import SwiftUI
import PresentationLayer
import PadelFinderCoreServices
import DataLayer
import DomainLayer

@main
struct PadelFinderApp: App {
    private let fetchAvailabilityUseCase: any FetchAvailabilityUseCaseProtocol
    
    init() {
        AppDependency.shared.assemble([
            CoreServicesAssembly(),
            DataAssembly()
        ])

        fetchAvailabilityUseCase = AppDependency.shared.resolve(FetchAvailabilityUseCaseProtocol.self)
    }
    
    var body: some Scene {
        WindowGroup {
            PadelCourtsTabFlowView(fetchAvailabilityUseCase: fetchAvailabilityUseCase)
        }
    }
}
