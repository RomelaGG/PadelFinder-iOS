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
    @State private var currentDate = Self.mockStartDate
    @State private var searchText = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xxxl) {
                header

                PadelSearchField(text: $searchText)

                CalendarHStack(
                    currentDate: $currentDate,
                    startDate: Self.mockStartDate,
                    dayCount: 10
                )
                .padding(.horizontal, -PadelDesignTokens.Spacing.xl)

                LazyVStack(spacing: PadelDesignTokens.Spacing.xxxl) {
                    ForEach(filteredCompanies) { company in
                        CompanyContainer(
                            companyName: company.name,
                            address: company.address,
                            distance: company.distance,
                            availableSlotsCount: company.availableSlotsCount,
                            slots: company.slots
                        ) {
                            InitialsBadge(
                                title: company.logoTitle,
                                backgroundColor: company.logoBackground,
                                foregroundColor: company.logoForeground,
                                lineColor: company.logoLine
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
            .padding(.top, PadelDesignTokens.Spacing.xl)
            .padding(.bottom, PadelDesignTokens.Spacing.xxxl)
        }
        .background(PadelDesignTokens.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension PadelCompaniesView {
    var header: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xs) {
            Text("Find a court")
                .font(PadelDesignTokens.Fonts.bodyStrong)
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)

            Text(selectedDateTitle)
                .font(PadelDesignTokens.Fonts.largeTitle)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var selectedDateTitle: String {
        let weekday = currentDate.formatted(.dateTime.weekday(.wide))
        let day = currentDate.formatted(.dateTime.day())
        let month = currentDate.formatted(.dateTime.month(.wide))

        return "\(weekday), \(day) \(month)"
    }

    var filteredCompanies: [MockPadelCompany] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return Self.mockCompanies
        }

        return Self.mockCompanies.filter { company in
            company.name.localizedCaseInsensitiveContains(query)
                || company.address.localizedCaseInsensitiveContains(query)
        }
    }

    static let mockStartDate: Date = {
        Calendar.current.date(
            from: DateComponents(year: 2026, month: 5, day: 26)
        ) ?? Date()
    }()

    static let mockCompanies: [MockPadelCompany] = [
        MockPadelCompany(
            name: "Northgate Padel Club",
            address: "Downtown",
            distance: "1.2 km",
            availableSlotsCount: 13,
            logoTitle: "NP",
            logoBackground: Color(red: 0.05, green: 0.27, blue: 0.20),
            logoForeground: Color(red: 0.58, green: 0.92, blue: 0.70),
            logoLine: Color(red: 0.22, green: 0.48, blue: 0.38),
            slots: [
                AvailableSlot("10:00", isAvailable: false),
                AvailableSlot("10:30"),
                AvailableSlot("11:00"),
                AvailableSlot("11:30"),
                AvailableSlot("12:00", isAvailable: false),
                AvailableSlot("12:30")
            ]
        ),
        MockPadelCompany(
            name: "Riverside Courts",
            address: "Riverside",
            distance: "3.4 km",
            availableSlotsCount: 19,
            logoTitle: "RC",
            logoBackground: Color(red: 0.10, green: 0.14, blue: 0.25),
            logoForeground: Color(red: 0.68, green: 0.78, blue: 0.98),
            logoLine: Color(red: 0.23, green: 0.30, blue: 0.46),
            slots: [
                AvailableSlot("08:00"),
                AvailableSlot("08:30", isAvailable: false),
                AvailableSlot("09:00"),
                AvailableSlot("09:30"),
                AvailableSlot("10:00"),
                AvailableSlot("10:30", isAvailable: false)
            ]
        ),
        MockPadelCompany(
            name: "Court 22 \u{00B7} Sports Hub",
            address: "West End",
            distance: "5.8 km",
            availableSlotsCount: 21,
            logoTitle: "C2",
            logoBackground: Color(red: 0.25, green: 0.10, blue: 0.10),
            logoForeground: Color(red: 0.96, green: 0.68, blue: 0.58),
            logoLine: Color(red: 0.47, green: 0.25, blue: 0.23),
            slots: [
                AvailableSlot("08:00"),
                AvailableSlot("08:30"),
                AvailableSlot("09:00", isAvailable: false),
                AvailableSlot("09:30"),
                AvailableSlot("10:00", isAvailable: false),
                AvailableSlot("10:30")
            ]
        ),
        MockPadelCompany(
            name: "Mesa Padel Center",
            address: "Mesa",
            distance: "6.1 km",
            availableSlotsCount: 9,
            logoTitle: "MP",
            logoBackground: Color(red: 0.12, green: 0.13, blue: 0.19),
            logoForeground: Color(red: 0.86, green: 0.88, blue: 0.94),
            logoLine: Color(red: 0.33, green: 0.34, blue: 0.43),
            slots: [
                AvailableSlot("12:00"),
                AvailableSlot("12:30", isAvailable: false),
                AvailableSlot("13:00"),
                AvailableSlot("13:30"),
                AvailableSlot("14:00")
            ]
        ),
        MockPadelCompany(
            name: "Greenline Courts",
            address: "Old Town",
            distance: "7.4 km",
            availableSlotsCount: 15,
            logoTitle: "GL",
            logoBackground: Color(red: 0.08, green: 0.23, blue: 0.14),
            logoForeground: Color(red: 0.73, green: 0.95, blue: 0.62),
            logoLine: Color(red: 0.25, green: 0.43, blue: 0.28),
            slots: [
                AvailableSlot("15:00"),
                AvailableSlot("15:30"),
                AvailableSlot("16:00", isAvailable: false),
                AvailableSlot("16:30"),
                AvailableSlot("17:00")
            ]
        )
    ]
}

private struct MockPadelCompany: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distance: String
    let availableSlotsCount: Int
    let logoTitle: String
    let logoBackground: Color
    let logoForeground: Color
    let logoLine: Color
    let slots: [AvailableSlot]
}

#Preview {
    PadelCompaniesView(
        viewModel: PadelCompaniesViewModel(
            state: PadelCompaniesViewModelState()
        )
    )
}
