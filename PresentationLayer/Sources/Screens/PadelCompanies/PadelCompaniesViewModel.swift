//
//  PadelCompaniesViewModel.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI
import Combine
import CoreNavigation
import CoreUI
import DomainLayer
import CoreDI
import CoreFormatting

// MARK: - State

struct PadelCompaniesViewModelState {
    var companies: [PadelCompanyRowModel] = []
    var isLoading = false
    var errorMessage: String?
}

// MARK: - Intent

enum PadelCompaniesViewModelIntent {
    case loadInitialAvailability(Date)
    case loadAvailability(Date)
    case navigateToProfile(Navigator<PadelCourtsTabNavigatorDestination>)
}

// MARK: - Row Model

struct PadelCompanyRowModel: Identifiable {
    let id: String
    let name: String
    let websiteAddress: String
    let distance: String
    let logoTitle: String
    let logoBackground: Color
    let logoForeground: Color
    let logoLine: Color
    let logoURL: URL?
    let slots: [AvailableSlot]

    var availableSlotsCount: Int {
        slots.filter(\.isAvailable).count
    }
}

// MARK: - ViewModel

@MainActor
final class PadelCompaniesViewModel: ObservableObject {
    @Published private(set) var state: PadelCompaniesViewModelState

    @Injected private var fetchAvailabilityUseCase: any FetchAvailabilityUseCaseProtocol
    
    @Injected private var dateFormatterProvider: DateFormatterProviderProtocol
    
    private var loadTask: Task<Void, Never>?
    private var hasLoadedInitialAvailability = false
    private var loadGeneration = 0

    init(state: PadelCompaniesViewModelState) {
        self.state = state
    }

    deinit {
        loadTask?.cancel()
    }

    func handleIntent(_ intent: PadelCompaniesViewModelIntent) {
        switch intent {
        case .loadInitialAvailability(let date):
            loadInitialAvailability(for: date)
        case .loadAvailability(let date):
            loadAvailability(for: date)
        case .navigateToProfile:
            break
        }
    }

    func refreshAvailability(for date: Date) async {
        let task = startLoadAvailability(for: date)
        await task.value
    }
}

// MARK: - handleIntent helpers

private extension PadelCompaniesViewModel {
    func loadInitialAvailability(for date: Date) {
        guard !hasLoadedInitialAvailability else { return }

        hasLoadedInitialAvailability = true
        loadAvailability(for: date)
    }

    func loadAvailability(for date: Date) {
        startLoadAvailability(for: date)
    }

    @discardableResult
    func startLoadAvailability(for date: Date) -> Task<Void, Never> {
        loadTask?.cancel()
        loadGeneration += 1

        let generation = loadGeneration

        let task = Task { [weak self] in
            guard let self else { return }
            await performLoadAvailability(for: date, generation: generation)
        }

        loadTask = task
        return task
    }

    func performLoadAvailability(for date: Date, generation: Int) async {
        let requestDate = dateFormatterProvider.isoDateFormatter.string(from: date)
        state.isLoading = true
        state.errorMessage = nil

        do {
            let companies = try await fetchAvailabilityUseCase.execute(date: requestDate)
            try Task.checkCancellation()
            guard isCurrentLoad(generation) else { return }

            state.companies = companies.map { mapCompany($0) }
            state.errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            guard isCurrentLoad(generation), !Task.isCancelled else { return }

            state.companies = []
            state.errorMessage = error.localizedDescription
        }

        guard isCurrentLoad(generation), !Task.isCancelled else { return }
        state.isLoading = false
    }

    func isCurrentLoad(_ generation: Int) -> Bool {
        loadGeneration == generation
    }
}

// MARK: - Mapping

private extension PadelCompaniesViewModel {
    func mapCompany(_ company: PadelCompany) -> PadelCompanyRowModel {
        let colors = badgeColors(for: company.companyID)
        
        return PadelCompanyRowModel(
            id: company.companyID,
            name: company.companyName,
            websiteAddress: websiteAddress(from: company.companyWebsite) ?? "Website unavailable",
            distance: "",
            logoTitle: initials(from: company.companyName, fallback: company.companyID),
            logoBackground: colors.background,
            logoForeground: colors.foreground,
            logoLine: colors.line,
            logoURL: company.companyLogo.flatMap(URL.init(string:)),
            slots: uniqueSlots(from: company.companyCourts)
        )
    }
    
    func uniqueSlots(from courts: [PadelCourt]) -> [AvailableSlot] {
        var orderedTimes: [String] = []
        var availabilityByTime: [String: Bool] = [:]
        
        for court in courts {
            for slot in court.timeSlots {
                if availabilityByTime[slot.startingTime] == nil {
                    orderedTimes.append(slot.startingTime)
                    availabilityByTime[slot.startingTime] = slot.isBookable
                } else if slot.isBookable {
                    availabilityByTime[slot.startingTime] = true
                }
            }
        }
        
        return orderedTimes.map { AvailableSlot(title: $0, isAvailable: availabilityByTime[$0] ?? false) }
    }
}

// MARK: - Additional Helpers

private extension PadelCompaniesViewModel {

    func websiteAddress(from website: String?) -> String? {
        guard let website = website?.trimmingCharacters(in: .whitespacesAndNewlines),
              !website.isEmpty else {
            return nil
        }

        return websiteHost(website) ?? website
    }

    func websiteHost(_ website: String) -> String? {
        URL(string: website)?
            .host(percentEncoded: false)?
            .replacingOccurrences(of: "www.", with: "")
    }

    func initials(from name: String, fallback: String) -> String {
        let initials = name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()

        return initials.isEmpty
            ? String(fallback.prefix(2)).uppercased()
            : initials
    }

    func badgeColors(for id: String) -> (background: Color, foreground: Color, line: Color) {
        let hue = Double(stableHash(id) % 360) / 360.0
        return (
            background: Color(hue: hue, saturation: 0.58, brightness: 0.32),
            foreground: Color.white.opacity(0.92),
            line: Color.white.opacity(0.22)
        )
    }

    func stableHash(_ value: String) -> UInt32 {
        value.unicodeScalars.reduce(UInt32(2166136261)) { hash, scalar in
            (hash ^ UInt32(scalar.value)) &* 16777619
        }
    }
}
