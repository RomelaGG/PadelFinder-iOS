//
//  AvailableSlotsHStack.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 01.06.26.
//

import SwiftUI

struct AvailableSlot: Identifiable, Hashable {
    let id: String
    let title: String
    let isAvailable: Bool

    init(_ title: String, isAvailable: Bool = true) {
        self.id = title
        self.title = title
        self.isAvailable = isAvailable
    }

    init(title: String, isAvailable: Bool = true) {
        self.init(title, isAvailable: isAvailable)
    }
}

struct AvailableSlotsHStack: View {
    private let slots: [AvailableSlot]
    private let onSlotSelected: (AvailableSlot) -> Void

    init(
        availableSlots: [String],
        onSlotSelected: @escaping (String) -> Void = { _ in }
    ) {
        self.slots = availableSlots.map { AvailableSlot($0) }
        self.onSlotSelected = { slot in
            onSlotSelected(slot.title)
        }
    }

    init(
        slots: [AvailableSlot],
        onSlotSelected: @escaping (AvailableSlot) -> Void = { _ in }
    ) {
        self.slots = slots
        self.onSlotSelected = onSlotSelected
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PadelDesignTokens.Spacing.availableSlotItem) {
                ForEach(slots) { slot in
                    AvailableSlotButton(slot: slot) {
                        onSlotSelected(slot)
                    }
                }
            }
            .padding(.horizontal, PadelDesignTokens.Spacing.availableSlotHorizontalInset)
            .padding(.vertical, PadelDesignTokens.Spacing.availableSlotShadowVerticalInset)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Available slots")
    }
}

private struct AvailableSlotButton: View {
    let slot: AvailableSlot
    let action: () -> Void

    var body: some View {
        if slot.isAvailable {
            Button(action: action) {
                slotLabel
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel)
        } else {
            slotLabel
                .accessibilityLabel(accessibilityLabel)
                .accessibilityAddTraits(.isStaticText)
        }
    }

    private var slotLabel: some View {
        Text(slot.title)
            .font(PadelDesignTokens.Fonts.availableSlot)
            .strikethrough(!slot.isAvailable, color: PadelDesignTokens.Colors.slotDisabledText)
            .foregroundStyle(foregroundColor)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .frame(
                width: PadelDesignTokens.Sizing.availableSlotWidth,
                height: PadelDesignTokens.Sizing.availableSlotHeight
            )
            .background(backgroundColor)
            .clipShape(slotShape)
            .overlay {
                slotShape
                    .stroke(borderColor, lineWidth: PadelDesignTokens.Sizing.availableSlotBorderWidth)
            }
            .contentShape(slotShape)
    }

    private var accessibilityLabel: String {
        slot.isAvailable ? slot.title : "\(slot.title), unavailable"
    }

    private var foregroundColor: Color {
        slot.isAvailable ? PadelDesignTokens.Colors.textPrimary : PadelDesignTokens.Colors.slotDisabledText
    }

    private var backgroundColor: Color {
        slot.isAvailable ? PadelDesignTokens.Colors.surface : PadelDesignTokens.Colors.slotDisabledBackground
    }

    private var borderColor: Color {
        slot.isAvailable ? PadelDesignTokens.Colors.slotBorder : PadelDesignTokens.Colors.slotDisabledBorder
    }

    private var slotShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.availableSlot, style: .continuous)
    }
}
