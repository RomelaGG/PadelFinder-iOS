//
//  PadelFinderApp.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 30.05.26.
//

import SwiftUI
import PresentationLayer
import PadelFinderCoreServices

@main
struct PadelFinderApp: App {
    // TODO: - register domain and data objects
    
    init() {
        AppDependency.shared.assemble([
            CoreServicesAssembly()
            // DataAssembly(),
            // DomainAssembly(),
            // PresentationAssembly(),
        ])
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            PadelCourtsTabFlowView()
        }
    }
}
