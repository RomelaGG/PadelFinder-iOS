//
//  PadelFinderApp.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 30.05.26.
//

import SwiftUI
import PresentationLayer

@main
struct PadelFinderApp: App {
    // TODO: - register domain and data objects
    
    var body: some Scene {
        WindowGroup {
            PadelCourtsTabFlowView()
        }
    }
}
