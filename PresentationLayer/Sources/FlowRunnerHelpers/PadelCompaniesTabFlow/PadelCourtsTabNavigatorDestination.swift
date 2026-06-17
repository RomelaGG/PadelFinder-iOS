//
//  PadelCourtsTabNavigatorDestination.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI
import CoreNavigation
import Foundation

enum PadelCourtsTabNavigatorDestination: NavigatorDestination {
    case padelCompaniesDetailsPage(companyID: String, date: Date)

    @ViewBuilder
    func view() -> some View {
        switch self {
        case let .padelCompaniesDetailsPage(companyID, date):
            ClubDetailsView(viewModel: .init(state: .init(companyID: companyID, date: date)))
        }
    }

}
