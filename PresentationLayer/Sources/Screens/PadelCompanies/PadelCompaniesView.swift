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

// MARK: - PadelCompaniesView

struct PadelCompaniesView: View {
    @EnvironmentObject var navigator: Navigator<PadelCourtsTabNavigatorDestination>
    @StateObject var viewModel: PadelCompaniesViewModel
    @State private var currentDate: Date
    @State private var searchText = ""
    @FocusState private var searchFieldFocusState: Bool

    init(viewModel: PadelCompaniesViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._currentDate = State(initialValue: Calendar.current.startOfDay(for: Date()))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.s) {
            VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xl) {
                header

                PadelSearchField(text: $searchText, isFocused: $searchFieldFocusState)

                CalendarHStack(
                    currentDate: $currentDate,
                    startDate: Calendar.current.startOfDay(for: Date()),
                    dayCount: 10
                )
                .padding(.horizontal, -PadelDesignTokens.Spacing.xl)
            }
            .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
            .padding(.top, PadelDesignTokens.Spacing.xl)

            ScrollView(showsIndicators: false) {
                companiesContent
                    .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
                    .padding(.bottom, PadelDesignTokens.Spacing.xxxl)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(PadelDesignTokens.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.handleIntent(.loadAvailability(currentDate))
        }
        .onChange(of: currentDate) { newDate in
            viewModel.handleIntent(.loadAvailability(newDate))
        }
        .onTapGesture {
            withAnimation {
                searchFieldFocusState = false
            }
        }
    }
}

// MARK: - Private components

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
    
    @ViewBuilder
    var companiesContent: some View {
        if viewModel.state.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 180)
        } else if let errorMessage = viewModel.state.errorMessage {
            VStack(spacing: PadelDesignTokens.Spacing.l) {
                Text(errorMessage)
                    .font(PadelDesignTokens.Fonts.body)
                    .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button("Retry") {
                    viewModel.handleIntent(.loadAvailability(currentDate))
                }
                .font(PadelDesignTokens.Fonts.bodyStrong)
                .foregroundStyle(PadelDesignTokens.Colors.accent)
            }
            .frame(maxWidth: .infinity, minHeight: 180)
        } else if filteredCompanies.isEmpty {
            Text(emptyStateText)
                .font(PadelDesignTokens.Fonts.body)
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 180)
        } else {
            LazyVStack(spacing: PadelDesignTokens.Spacing.xxxl) {
                ForEach(filteredCompanies) { company in
                    CompanyContainer(
                        companyName: company.name,
                        address: company.address,
                        distance: company.distance,
                        availableSlotsCount: company.availableSlotsCount,
                        slots: company.slots,
                        onCompanySelected: { openDetails(for: company) },
                        onSlotSelected: { _ in openDetails(for: company) }
                    ) {
                        companyLogo(for: company)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func companyLogo(for company: PadelCompanyRowModel) -> some View {
        if let logoURL = company.logoURL {
            AsyncImage(url: logoURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    fallbackLogo(for: company)
                @unknown default:
                    fallbackLogo(for: company)
                }
            }
        } else {
            fallbackLogo(for: company)
        }
    }
    
    func fallbackLogo(for company: PadelCompanyRowModel) -> some View {
        InitialsBadge(
            title: company.logoTitle,
            backgroundColor: company.logoBackground,
            foregroundColor: company.logoForeground,
            lineColor: company.logoLine
        )
    }
}

// MARK: - Navigation

private extension PadelCompaniesView {
    func openDetails(for company: PadelCompanyRowModel) {
        navigator.push(.padelCompaniesDetailsPage(companyID: company.id, date: currentDate))
    }
}

// MARK: - Private helpers

private extension PadelCompaniesView {
    var selectedDateTitle: String {
        let weekday = currentDate.formatted(.dateTime.weekday(.wide))
        let day = currentDate.formatted(.dateTime.day())
        let month = currentDate.formatted(.dateTime.month(.wide))

        return "\(weekday), \(day) \(month)"
    }

    var filteredCompanies: [PadelCompanyRowModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return viewModel.state.companies
        }

        return viewModel.state.companies.filter { company in
            company.name.localizedCaseInsensitiveContains(query)
                || company.address.localizedCaseInsensitiveContains(query)
        }
    }

    var emptyStateText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "No courts are available for this date."
            : "No courts match your search."
    }
}
