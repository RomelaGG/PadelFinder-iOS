//
//  PadelCourtsTabNavigatorDestination.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI
import CoreNavigation

enum PadelCourtsTabNavigatorDestination: NavigatorDestination {
    case padelCompaniesDetailsPage
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .padelCompaniesDetailsPage:
            EmptyView()
        }
    }
    
}
