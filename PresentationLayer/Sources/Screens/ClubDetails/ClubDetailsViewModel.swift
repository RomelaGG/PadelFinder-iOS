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
    var websiteAddress = ""
    var coverImageURL: URL?
    var logoURL: URL?
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
    case loadInitialAvailability(Date)
    case loadAvailability(Date)
}

// MARK: - Court Row Model

struct ClubCourtRowModel: Identifiable {
    let id: String
    let name: String
    let pricePerHour: Int?
    let address: String?
    let slots: [AvailableSlot]
}

// MARK: - ViewModel

@MainActor
final class ClubDetailsViewModel: ObservableObject {
    @Published private(set) var state: ClubDetailsViewModelState

    @Injected private var fetchCompanyAvailabilityUseCase: any FetchCompanyAvailabilityUseCaseProtocol

    @Injected private var dateFormatterProvider: DateFormatterProviderProtocol

    private var loadTask: Task<Void, Never>?
    private var hasLoadedInitialAvailability = false
    private var loadGeneration = 0

    init(state: ClubDetailsViewModelState) {
        self.state = state
    }

    deinit {
        loadTask?.cancel()
    }

    func handleIntent(_ intent: ClubDetailsViewModelIntent) {
        switch intent {
        case .loadInitialAvailability(let date):
            loadInitialAvailability(for: date)
        case .loadAvailability(let date):
            loadAvailability(for: date)
        }
    }

    func refreshAvailability(for date: Date) async {
        let task = startLoadAvailability(for: date)
        await task.value
    }
}

// MARK: - Loading

private extension ClubDetailsViewModel {
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
        let companyID = state.companyID
        let requestDate = dateFormatterProvider.isoDateFormatter.string(from: date)
        state.isLoading = true
        state.errorMessage = nil

        do {
            let company = try await fetchCompanyAvailabilityUseCase.execute(companyId: companyID, date: requestDate)
            try Task.checkCancellation()
            guard isCurrentLoad(generation) else { return }

            apply(company)
            state.errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            guard isCurrentLoad(generation), !Task.isCancelled else { return }

            state.courts = []
            state.slots = []
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

private extension ClubDetailsViewModel {
    func apply(_ company: PadelCompany) {
        let colors = badgeColors(for: company.companyID)

        state.headerTitle = company.companyName
        state.websiteAddress = websiteAddress(from: company.companyWebsite) ?? "Website unavailable"
        state.coverImageURL = company.companyCoverImage.flatMap(URL.init(string:))
        state.logoURL = company.companyLogo.flatMap(URL.init(string:))
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
            address: courtAddress(from: court.address),
            slots: court.timeSlots.map { AvailableSlot(title: $0.startingTime, isAvailable: $0.isBookable) }
        )
    }

    func courtAddress(from address: String?) -> String? {
        guard let address = address?.trimmingCharacters(in: .whitespacesAndNewlines),
              !address.isEmpty else {
            return nil
        }

        return address
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
                    availabilityByTime[slot.startingTime] = slot.isBookable
                } else if slot.isBookable {
                    availabilityByTime[slot.startingTime] = true
                }
            }
        }

        return orderedTimes.map { AvailableSlot(title: $0, isAvailable: availabilityByTime[$0] ?? false) }
    }
}

// MARK: - Helpers

private extension ClubDetailsViewModel {
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
