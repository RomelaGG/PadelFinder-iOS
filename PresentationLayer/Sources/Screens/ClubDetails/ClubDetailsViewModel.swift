//
//  ClubDetailsViewModel.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 17.06.26.
//

import SwiftUI
import Combine
import CoreUI
import DomainLayer
import CoreDI
import CoreFormatting

// MARK: - State

struct ClubDetailsViewModelState {
    let companyID: String
    let initialDate: Date

    var headerTitle = ""
    var location = ""
    var imageURL: URL?
    var logoTitle = ""
    var logoBackground: Color = .gray
    var logoForeground: Color = .white
    var logoLine: Color = .white.opacity(0.2)
    var slots: [AvailableSlot] = []
    var courts: [ClubCourtRowModel] = []
    var isLoading = false
    var errorMessage: String?

    init(companyID: String, date: Date) {
        self.companyID = companyID
        self.initialDate = date
    }
}

// MARK: - Intent

enum ClubDetailsViewModelIntent {
    case loadAvailability(Date)
}

// MARK: - Court Row Model

struct ClubCourtRowModel: Identifiable {
    let id: String
    let name: String
    let pricePerHour: Int?
    let imageURL: URL?
    let slots: [AvailableSlot]

    var freeCount: Int {
        slots.filter(\.isAvailable).count
    }
}

// MARK: - ViewModel

@MainActor
final class ClubDetailsViewModel: ObservableObject {
    @Published private(set) var state: ClubDetailsViewModelState

    @Injected private var fetchCompanyAvailabilityUseCase: any FetchCompanyAvailabilityUseCaseProtocol

    @Injected private var dateFormatterProvider: DateFormatterProviderProtocol

    private var loadTask: Task<Void, Never>?

    init(state: ClubDetailsViewModelState) {
        self.state = state
    }

    deinit {
        loadTask?.cancel()
    }

    func handleIntent(_ intent: ClubDetailsViewModelIntent) {
        switch intent {
        case .loadAvailability(let date):
            loadAvailability(for: date)
        }
    }
}

// MARK: - Loading

private extension ClubDetailsViewModel {
    func loadAvailability(for date: Date) {
        loadTask?.cancel()

        let companyID = state.companyID
        let requestDate = dateFormatterProvider.isoDateFormatter.string(from: date)
        state.isLoading = true
        state.errorMessage = nil

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let company = try await fetchCompanyAvailabilityUseCase.execute(companyId: companyID, date: requestDate)
                try Task.checkCancellation()
                apply(company)
                state.errorMessage = nil
            } catch is CancellationError {
                return
            } catch {
                state.courts = []
                state.slots = []
                state.errorMessage = error.localizedDescription
            }

            state.isLoading = false
        }
    }
}

// MARK: - Mapping

private extension ClubDetailsViewModel {
    func apply(_ company: PadelCompany) {
        let colors = badgeColors(for: company.companyID)

        state.headerTitle = company.companyName
        state.location = company.companyWebsite.flatMap(websiteHost) ?? "Website unavailable"
        state.imageURL = firstImageURL(from: company.companyCourts)
        state.logoTitle = initials(from: company.companyName, fallback: company.companyID)
        state.logoBackground = colors.background
        state.logoForeground = colors.foreground
        state.logoLine = colors.line
        state.slots = uniqueSlots(from: company.companyCourts)
        state.courts = company.companyCourts.map(mapCourt)
    }

    func mapCourt(_ court: PadelCourt) -> ClubCourtRowModel {
        ClubCourtRowModel(
            id: court.id,
            name: court.courtName,
            pricePerHour: court.pricePerHour,
            imageURL: court.imageURL.flatMap(URL.init(string:)),
            slots: court.timeSlots.map { AvailableSlot(title: $0.startingTime, isAvailable: $0.availability) }
        )
    }

    func firstImageURL(from courts: [PadelCourt]) -> URL? {
        courts.lazy
            .compactMap(\.imageURL)
            .compactMap(URL.init(string:))
            .first
    }

    /// Aggregate "Available time" strip: the union of every court's slots, where
    /// a time is available if **any** court is free at that time.
    func uniqueSlots(from courts: [PadelCourt]) -> [AvailableSlot] {
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

        return orderedTimes.map { AvailableSlot(title: $0, isAvailable: availabilityByTime[$0] ?? false) }
    }
}

// MARK: - Helpers

private extension ClubDetailsViewModel {
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
