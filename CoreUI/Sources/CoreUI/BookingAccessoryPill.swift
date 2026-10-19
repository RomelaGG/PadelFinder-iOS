//
//  BookingAccessoryPill.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - BookingAccessoryPill

/// The slot a player tapped, carried above the tab bar so it survives navigation.
///
/// On iOS 26 this is handed to `.tabViewBottomAccessory`, which places it in the glass
/// layer directly above the tab bar and tells it — through
/// `\.tabViewBottomAccessoryPlacement` — whether it has been given a full row or a
/// compact inline slot. Below iOS 26 the caller overlays it instead.
public struct BookingAccessoryPill: View {
    private let clubName: String
    private let time: String
    private let price: String
    private let onTap: () -> Void

    public init(
        clubName: String,
        time: String,
        price: String,
        onTap: @escaping () -> Void
    ) {
        self.clubName = clubName
        self.time = time
        self.price = price
        self.onTap = onTap
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            PlacementAwarePill(content: content, isCompact: nil, onTap: onTap)
        } else {
            PillButton(content: content, isCompact: false, onTap: onTap)
        }
    }

    private var content: BookingAccessoryContent {
        BookingAccessoryContent(clubName: clubName, time: time, price: price)
    }
}

// MARK: - BookingAccessoryContent

struct BookingAccessoryContent {
    let clubName: String
    let time: String
    let price: String

    /// "Lemans Padel · 19:00" — what survives when the pill is given an inline slot.
    var headline: String {
        "\(clubName) · \(time)"
    }
}

// MARK: - PlacementAwarePill

/// Separated out because `\.tabViewBottomAccessoryPlacement` is iOS 26 only and cannot
/// be declared as a stored property on a type that also has to compile for iOS 16.
@available(iOS 26.0, *)
private struct PlacementAwarePill: View {
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement

    let content: BookingAccessoryContent
    let isCompact: Bool?
    let onTap: () -> Void

    var body: some View {
        PillButton(
            content: content,
            isCompact: isCompact ?? (placement == .inline),
            onTap: onTap
        )
    }
}

// MARK: - PillButton

private struct PillButton: View {
    let content: BookingAccessoryContent
    let isCompact: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PadelDesignTokens.Spacing.l) {
                VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xxs) {
                    Text(content.headline)
                        .font(PadelDesignTokens.Fonts.callout)
                        .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                        .lineLimit(1)

                    if !isCompact {
                        Text(content.price)
                            .font(PadelDesignTokens.Fonts.caption)
                            .foregroundStyle(PadelDesignTokens.Colors.textSupport)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: PadelDesignTokens.Spacing.m)

                Text("Book")
                    .font(PadelDesignTokens.Fonts.callout)
                    .foregroundStyle(PadelDesignTokens.Colors.onAccent)
                    .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
                    .padding(.vertical, PadelDesignTokens.Spacing.m)
                    .background(PadelDesignTokens.Colors.accent, in: Capsule())
            }
            .padding(.leading, PadelDesignTokens.Spacing.xxxl)
            .padding(.trailing, PadelDesignTokens.Spacing.s)
            .padding(.vertical, PadelDesignTokens.Spacing.s)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .padelGlass(in: Capsule(), interactive: true)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(content.headline), \(content.price)")
        .accessibilityHint("Book this court")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: PadelDesignTokens.Spacing.xxxl) {
        BookingAccessoryPill(
            clubName: "Lemans Padel",
            time: "19:00",
            price: "60₾ · 90 min",
            onTap: {}
        )

        BookingAccessoryPill(
            clubName: "Gym Breeze",
            time: "08:30",
            price: "45₾ · 60 min",
            onTap: {}
        )
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
