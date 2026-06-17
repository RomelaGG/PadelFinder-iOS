//
//  SlotPillsRow.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 17.06.26.
//

import DesignSystem
import SwiftUI

/// A horizontal, **non-interactive** row of time-slot pills.
///
/// Mirrors the "Available time" / per-court time strips from the Club design,
/// but the pills are plain labels (no `Button`) so they can never be tapped —
/// booking is intentionally out of scope for now. Available pills read on a
/// surface background; unavailable ones are muted and struck through.
public struct SlotPillsRow: View {
    public enum Size {
        case regular
        case compact
    }

    private let slots: [AvailableSlot]
    private let size: Size

    public init(slots: [AvailableSlot], size: Size = .regular) {
        self.slots = slots
        self.size = size
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PadelDesignTokens.Spacing.m) {
                ForEach(slots) { slot in
                    pill(for: slot)
                }
            }
            .padding(.horizontal, PadelDesignTokens.Spacing.xl)
            .padding(.vertical, PadelDesignTokens.Spacing.xs)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Available times")
    }

    private func pill(for slot: AvailableSlot) -> some View {
        Text(slot.title)
            .font(font)
            .strikethrough(!slot.isAvailable, color: PadelDesignTokens.Colors.textDisabled)
            .foregroundStyle(foregroundColor(for: slot))
            .lineLimit(1)
            .frame(height: height)
            .padding(.horizontal, horizontalPadding)
            .background(backgroundColor(for: slot))
            .clipShape(pillShape)
            .overlay {
                pillShape
                    .stroke(borderColor(for: slot), lineWidth: PadelDesignTokens.Sizing.hairline)
            }
            .accessibilityLabel(slot.isAvailable ? slot.title : "\(slot.title), unavailable")
            .accessibilityAddTraits(.isStaticText)
    }

    private var font: Font {
        size == .regular ? PadelDesignTokens.Fonts.bodyStrong : PadelDesignTokens.Fonts.captionStrong
    }

    private var height: CGFloat {
        size == .regular ? 40 : 34
    }

    private var horizontalPadding: CGFloat {
        size == .regular ? PadelDesignTokens.Spacing.xxxxl : PadelDesignTokens.Spacing.xl
    }

    private func foregroundColor(for slot: AvailableSlot) -> Color {
        slot.isAvailable ? PadelDesignTokens.Colors.textPrimary : PadelDesignTokens.Colors.textDisabled
    }

    private func backgroundColor(for slot: AvailableSlot) -> Color {
        slot.isAvailable ? PadelDesignTokens.Colors.surface : PadelDesignTokens.Colors.surfaceMuted
    }

    private func borderColor(for slot: AvailableSlot) -> Color {
        PadelDesignTokens.Colors.border
    }

    private var pillShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.l, style: .continuous)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        SlotPillsRow(slots: [
            AvailableSlot("08:00"),
            AvailableSlot("08:30", isAvailable: false),
            AvailableSlot("09:00"),
            AvailableSlot("09:30")
        ])

        SlotPillsRow(slots: [
            AvailableSlot("08:00"),
            AvailableSlot("08:30", isAvailable: false),
            AvailableSlot("09:00")
        ], size: .compact)
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
