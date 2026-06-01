//
//  PadelCompaniesView.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI
import CoreNavigation
import CoreUI
import DesignSystem

struct PadelCompaniesView: View {
    @EnvironmentObject var navigator: Navigator<PadelCourtsTabNavigatorDestination>
    @StateObject var viewModel: PadelCompaniesViewModel
    @State var currentDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarHStack(currentDate: $currentDate)
            AvailableSlotsHStack(
                slots: [
                    AvailableSlot("08:00", isAvailable: true),
                    AvailableSlot("08:30", isAvailable: false),
                    AvailableSlot("09:00", isAvailable: true),
                    AvailableSlot("09:30", isAvailable: true),
                    AvailableSlot("10:00", isAvailable: true),
                    AvailableSlot("10:30", isAvailable: false),
                    AvailableSlot("11:00", isAvailable: true),
                    AvailableSlot("11:30", isAvailable: true),
                    AvailableSlot("12:00", isAvailable: false),
                    AvailableSlot("12:30", isAvailable: true),
                ]
            )
        }
    }
}
