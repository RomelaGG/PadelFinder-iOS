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
    
    public init() { }
    
    public var body: some View {
        PadelCourtsTabFlowRunnerFactory().makeView(navigator: navigator)
    }
}
