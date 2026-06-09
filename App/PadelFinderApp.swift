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
import DataLayer
import DomainLayer
import CoreFormatting

@main
struct PadelFinderApp: App {
    init() {
        AppDependency.shared.assemble([
            CoreNetworkingAssembly(),
            CoreFormatterAssembly(),
            DataAssembly(),
            DomainAssembly()
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            PadelCourtsTabFlowView()
        }
    }
}
