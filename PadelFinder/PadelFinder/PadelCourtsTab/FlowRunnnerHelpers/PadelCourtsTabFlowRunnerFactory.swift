//
//  PadelFlowRunnerFactory.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI

struct PadelCourtsTabFlowRunnerFactory {
    func makeView(navigator: Navigator<PadelCourtsTabNavigatorDestination>) -> some View {
        NavigationHost(navigator: navigator) {
            EmptyView()
        }
    }
}
