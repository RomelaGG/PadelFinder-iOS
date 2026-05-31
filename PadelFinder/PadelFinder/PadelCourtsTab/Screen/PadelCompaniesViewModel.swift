//
//  PadelCompaniesViewModel.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI
import Combine

struct PadelCompaniesViewModelState {
    
}

enum PadelCompaniesViewModelIntent {
    case navigateToProfile(Navigator<PadelCourtsTabNavigatorDestination>)
}


final class PadelCompaniesViewModel: ObservableObject {
    @Published private(set) var state: PadelCompaniesViewModelState
    
    init(state: PadelCompaniesViewModelState) {
        self.state = state
    }
    
    func handleIntent(intent: PadelCompaniesViewModelIntent) {
        switch intent {
        case .navigateToProfile(let navigator):
            print("navigated")
        }
    }
}
