//
//  PadelCourtsTabFlowRunnerFactory.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI
import CoreNavigation

struct PadelCourtsTabFlowView: View {
    @StateObject private var navigator = Navigator<PadelCourtsTabNavigatorDestination>()
    private var factory = PadelCourtsTabFlowRunnerFactory()
    
    var body: some View {
        factory.makeView(navigator: navigator)
    }
}
