//
//  PadelListRow.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelListRow

/// One settings row: icon, title, and something on the right.
///
/// A `nil` action makes the row inert — drawn, readable, but not tappable.
/// That is what the rows with nothing behind them yet use: a row that
/// highlights and then does nothing is a worse promise than one that never
/// looked tappable.
public struct PadelListRow: View {

    public enum Accessory {
        case chevron
        case value(String)
        case toggle(Binding<Bool>)
        case none
    }

    private let icon: String
    private let title: String
    private let accessory: Accessory
    private let isDestructive: Bool
    private let action: (() -> Void)?

    public init(
        icon: String,
        title: String,
        accessory: Accessory = .chevron,
        isDestructive: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.accessory = accessory
        self.isDestructive = isDestructive
        self.action = action
    }

    public var body: some View {
        if let action {
            Button(action: action) {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            rowContent
        }
    }

    /// Leading inset for the divider between two rows: the icon's width plus
    /// the gap after it, so the line starts under the title.
    static let dividerInset: CGFloat =
        PadelListRow.iconWidth + PadelDesignTokens.Spacing.xl

    private static let iconWidth: CGFloat = 20

    private var rowContent: some View {
        HStack(spacing: PadelDesignTokens.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(foregroundColor)
                .frame(width: Self.iconWidth)
                .accessibilityHidden(true)

            Text(title)
                .font(PadelDesignTokens.Fonts.subheadline)
                .foregroundStyle(foregroundColor)

            Spacer(minLength: PadelDesignTokens.Spacing.m)

            accessoryView
        }
        .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
        .frame(height: PadelDesignTokens.Sizing.listRow)
        .contentShape(Rectangle())
    }

    private var foregroundColor: Color {
        isDestructive
            ? PadelDesignTokens.Colors.error
            : PadelDesignTokens.Colors.textPrimary
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(PadelDesignTokens.Fonts.caption)
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                .accessibilityHidden(true)

        case let .value(value):
            Text(value)
                .font(PadelDesignTokens.Fonts.body)
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)

        case let .toggle(binding):
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(PadelDesignTokens.Colors.accent)

        case .none:
            EmptyView()
        }
    }
}

// MARK: - PadelListCard

/// A group of rows in one card, with the inset dividers between them.
///
/// Takes the rows as an array rather than a `ViewBuilder` because the dividers
/// have to go *between* them, and that needs to know how many there are.
public struct PadelListCard: View {
    private let rows: [PadelListRow]

    public init(_ rows: [PadelListRow]) {
        self.rows = rows
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                row

                if index < rows.count - 1 {
                    Divider()
                        .overlay(PadelDesignTokens.Colors.border)
                        .padding(.leading, PadelListRow.dividerInset
                            + PadelDesignTokens.Spacing.xxxl)
                }
            }
        }
        .background(PadelDesignTokens.Colors.surface)
        .clipShape(shape)
        .overlay {
            shape.stroke(
                PadelDesignTokens.Colors.border,
                lineWidth: PadelDesignTokens.Sizing.hairline
            )
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xxxl, style: .continuous)
    }
}

#Preview {
    VStack(spacing: PadelDesignTokens.Layout.fieldGap) {
        PadelListCard([
            PadelListRow(icon: "globe", title: "Language", accessory: .value("English")),
            PadelListRow(icon: "questionmark.circle", title: "Help"),
            PadelListRow(icon: "doc.text", title: "Terms of Service"),
            PadelListRow(icon: "hand.raised", title: "Privacy Policy")
        ])

        PadelListCard([
            PadelListRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Sign out",
                accessory: .none,
                isDestructive: true,
                action: {}
            ),
            PadelListRow(
                icon: "trash",
                title: "Delete account",
                accessory: .none,
                isDestructive: true,
                action: {}
            )
        ])

        PadelListCard([
            PadelListRow(icon: "bell", title: "Notifications", accessory: .toggle(.constant(true)))
        ])
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
