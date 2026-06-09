//
//  CompanyContainer.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

import DesignSystem
import SwiftUI

// MARK: - CompanyInformation

public struct CompanyContainer: View {
    private let logo: AnyView
    private let companyName: String
    private let address: String
    private let distance: String
    private let availableSlotsCount: Int
    private let slots: [AvailableSlot]
    private let onCompanySelected: () -> Void
    private let onSlotSelected: (AvailableSlot) -> Void

    public init<Logo: View>(
        companyName: String,
        address: String,
        distance: String,
        availableSlotsCount: Int,
        slots: [AvailableSlot],
        onCompanySelected: @escaping () -> Void = {},
        onSlotSelected: @escaping (AvailableSlot) -> Void = { _ in },
        @ViewBuilder logo: () -> Logo
    ) {
        self.logo = AnyView(logo())
        self.companyName = companyName
        self.address = address
        self.distance = distance
        self.availableSlotsCount = availableSlotsCount
        self.slots = slots
        self.onCompanySelected = onCompanySelected
        self.onSlotSelected = onSlotSelected
    }

    public init<Logo: View>(
        companyName: String,
        address: String,
        distance: String,
        availableSlotsCount: Int,
        availableSlots: [String],
        onCompanySelected: @escaping () -> Void = {},
        onSlotSelected: @escaping (String) -> Void = { _ in },
        @ViewBuilder logo: () -> Logo
    ) {
        self.init(
            companyName: companyName,
            address: address,
            distance: distance,
            availableSlotsCount: availableSlotsCount,
            slots: availableSlots.map { AvailableSlot($0) },
            onCompanySelected: onCompanySelected,
            onSlotSelected: { onSlotSelected($0.title) },
            logo: logo
        )
    }

    public init(
        image: Image,
        companyName: String,
        address: String,
        distance: String,
        availableSlotsCount: Int,
        slots: [AvailableSlot],
        onCompanySelected: @escaping () -> Void = {},
        onSlotSelected: @escaping (AvailableSlot) -> Void = { _ in }
    ) {
        self.init(
            companyName: companyName,
            address: address,
            distance: distance,
            availableSlotsCount: availableSlotsCount,
            slots: slots,
            onCompanySelected: onCompanySelected,
            onSlotSelected: onSlotSelected
        ) {
            image
                .resizable()
                .scaledToFill()
        }
    }

    public init(
        image: Image,
        companyName: String,
        address: String,
        distance: String,
        availableSlotsCount: Int,
        availableSlots: [String],
        onCompanySelected: @escaping () -> Void = {},
        onSlotSelected: @escaping (String) -> Void = { _ in }
    ) {
        self.init(
            companyName: companyName,
            address: address,
            distance: distance,
            availableSlotsCount: availableSlotsCount,
            availableSlots: availableSlots,
            onCompanySelected: onCompanySelected,
            onSlotSelected: onSlotSelected
        ) {
            image
                .resizable()
                .scaledToFill()
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            companyInformation
                .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
                .padding(.top, PadelDesignTokens.Spacing.xxxl)
                .padding(.bottom, PadelDesignTokens.Spacing.xxxxl)

            Divider()
                .overlay(PadelDesignTokens.Colors.border)
                .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)

            AvailableSlotsHStack(slots: slots, onSlotSelected: onSlotSelected)
                .padding(.vertical, PadelDesignTokens.Spacing.m)
        }
        .background(PadelDesignTokens.Colors.surface)
        .clipShape(containerShape)
        .overlay {
            containerShape
                .stroke(
                    PadelDesignTokens.Colors.border,
                    lineWidth: PadelDesignTokens.Sizing.hairline
                )
        }
        .shadow(
            color: PadelDesignTokens.Colors.shadowRaised,
            radius: PadelDesignTokens.Shadow.raisedRadius,
            x: PadelDesignTokens.Shadow.raisedX,
            y: PadelDesignTokens.Shadow.raisedY
        )
    }
}

// MARK: - companyInformation

private extension CompanyContainer {
    var companyInformation: some View {
        Button(action: onCompanySelected) {
            HStack(spacing: PadelDesignTokens.Spacing.xxl) {
                logo
                    .frame(
                        width: PadelDesignTokens.Sizing.mediaThumbnail,
                        height: PadelDesignTokens.Sizing.mediaThumbnail
                    )
                    .clipShape(imageShape)

                VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xs) {
                    Text(companyName)
                        .font(PadelDesignTokens.Fonts.title)
                        .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    metadataLine
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                arrowButton
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    var metadataLine: some View {
        HStack(spacing: PadelDesignTokens.Spacing.m) {
            ForEach(Array(metadataItems.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    metadataSeparator
                }

                Text(item)
                    .foregroundStyle(metadataColor(for: item))
            }

        }
        .font(PadelDesignTokens.Fonts.body)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
    }

    var metadataSeparator: some View {
        Text("\u{00B7}")
            .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
    }

    var metadataItems: [String] {
        [address, distance, slotsCountText].filter {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    func metadataColor(for item: String) -> Color {
        item == slotsCountText
            ? PadelDesignTokens.Colors.accent
            : PadelDesignTokens.Colors.textSecondary
    }

    var accessibilityLabel: String {
        ([companyName] + metadataItems).joined(separator: ", ")
    }

    var slotsCountText: String {
        "\(availableSlotsCount) \(availableSlotsCount == 1 ? "slot" : "slots")"
    }
}

// MARK: - Shapes

private extension CompanyContainer {
    var containerShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: PadelDesignTokens.Radius.xxxl,
            style: .continuous
        )
    }

    var imageShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: PadelDesignTokens.Radius.xl,
            style: .continuous
        )
    }
}

// MARK: - arrowButton

private extension CompanyContainer {
    var arrowButton: some View {
        Image(systemName: "chevron.right")
            .font(PadelDesignTokens.Fonts.symbol)
            .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
            .frame(
                width: PadelDesignTokens.Sizing.actionControl,
                height: PadelDesignTokens.Sizing.actionControl
            )
            .background(PadelDesignTokens.Colors.surfaceMuted)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack {
        CompanyContainer(
            image: Image(systemName: "building.2.fill"),
            companyName: "Riverside Courts",
            address: "Riverside",
            distance: "3.4 km",
            availableSlotsCount: 19,
            slots: [
                AvailableSlot("08:00"),
                AvailableSlot("08:30", isAvailable: false),
                AvailableSlot("09:00"),
                AvailableSlot("09:30"),
                AvailableSlot("10:00")
            ]
        )
        .padding()
    }
    .background(PadelDesignTokens.Colors.background)
}
