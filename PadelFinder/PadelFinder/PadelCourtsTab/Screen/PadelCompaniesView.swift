//
//  PadelCompaniesView.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI

struct PadelCompaniesView: View {
    @EnvironmentObject var navigator: Navigator<PadelCourtsTabNavigatorDestination>
    @StateObject var viewModel: PadelCompaniesViewModel
    @State var currentDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarHStack(currentDate: $currentDate)
        }
    }
}
