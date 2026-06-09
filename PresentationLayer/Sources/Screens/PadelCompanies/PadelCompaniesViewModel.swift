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

// MARK: - State

struct PadelCompaniesViewModelState {
    var companies: [PadelCompanyRowModel] = []
    var isLoading = false
    var errorMessage: String?
}

// MARK: - Intent

enum PadelCompaniesViewModelIntent {
    case loadAvailability(Date)
    case navigateToProfile(Navigator<PadelCourtsTabNavigatorDestination>)
}

struct PadelCompanyRowModel: Identifiable {
    let id: String
    let name: String
    let address: String
    let distance: String
    let logoTitle: String
    let logoBackground: Color
    let logoForeground: Color
    let logoLine: Color
    let imageURL: URL?
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
    private var loadTask: Task<Void, Never>?
    
    init(state: PadelCompaniesViewModelState) {
        self.state = state
    }

    deinit {
        loadTask?.cancel()
    }
    
    func handleIntent(intent: PadelCompaniesViewModelIntent) {
        switch intent {
        case .loadAvailability(let date):
            loadAvailability(for: date)
        case .navigateToProfile:
            print("navigated")
        }
    }

    private func loadAvailability(for date: Date) {
        loadTask?.cancel()
        let requestDate = Self.requestDateFormatter.string(from: date)

        state.isLoading = true
        state.errorMessage = nil

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let companies = try await fetchAvailabilityUseCase.execute(date: requestDate)
                try Task.checkCancellation()
                state.companies = companies.map(Self.mapCompany)
                state.errorMessage = nil
            } catch is CancellationError {
                return
            } catch {
                state.companies = []
                state.errorMessage = error.localizedDescription
            }

            state.isLoading = false
        }
    }
}

private extension PadelCompaniesViewModel {
    static let requestDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func mapCompany(_ company: PadelCompany) -> PadelCompanyRowModel {
        let colors = badgeColors(for: company.companyID)

        return PadelCompanyRowModel(
            id: company.companyID,
            name: company.companyName,
            address: company.companyWebsite.flatMap(websiteHost) ?? "Website unavailable",
            distance: "",
            logoTitle: initials(from: company.companyName, fallback: company.companyID),
            logoBackground: colors.background,
            logoForeground: colors.foreground,
            logoLine: colors.line,
            imageURL: firstImageURL(from: company.companyCourts),
            slots: uniqueSlots(from: company.companyCourts)
        )
    }

    static func firstImageURL(from courts: [PadelCourt]) -> URL? {
        courts.lazy
            .compactMap(\.imageURL)
            .compactMap(URL.init(string:))
            .first
    }

    static func uniqueSlots(from courts: [PadelCourt]) -> [AvailableSlot] {
        var orderedTimes: [String] = []
        var availabilityByTime: [String: Bool] = [:]

        for court in courts {
            for slot in court.timeSlots {
                if availabilityByTime[slot.startingTime] == nil {
                    orderedTimes.append(slot.startingTime)
                    availabilityByTime[slot.startingTime] = slot.availability
                } else if slot.availability {
                    availabilityByTime[slot.startingTime] = true
                }
            }
        }

        return orderedTimes.map { time in
            AvailableSlot(title: time, isAvailable: availabilityByTime[time] ?? false)
        }
    }

    static func websiteHost(_ website: String) -> String? {
        guard let host = URL(string: website)?.host(percentEncoded: false) else {
            return nil
        }

        return host.replacingOccurrences(of: "www.", with: "")
    }

    static func initials(from name: String, fallback: String) -> String {
        let initials = name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()

        if initials.isEmpty {
            return String(fallback.prefix(2)).uppercased()
        }

        return initials
    }

    static func badgeColors(for id: String) -> (background: Color, foreground: Color, line: Color) {
        let hash = stableHash(id)
        let hue = Double(hash % 360) / 360.0
        let background = Color(hue: hue, saturation: 0.58, brightness: 0.32)

        return (
            background: background,
            foreground: Color.white.opacity(0.92),
            line: Color.white.opacity(0.22)
        )
    }

    static func stableHash(_ value: String) -> UInt32 {
        value.unicodeScalars.reduce(UInt32(2166136261)) { hash, scalar in
            (hash ^ UInt32(scalar.value)) &* 16777619
        }
    }
}
