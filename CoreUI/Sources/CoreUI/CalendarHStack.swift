//
//  CalendarHStack.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import DesignSystem
import SwiftUI

public struct CalendarHStack: View {
    @Binding var currentDate: Date

    private let calendar: Calendar
    private let startDate: Date
    private let dayCount: Int

    public init(
        currentDate: Binding<Date>,
        calendar: Calendar = .current,
        startDate: Date = Date(),
        dayCount: Int = 21
    ) {
        self._currentDate = currentDate
        self.calendar = calendar
        self.startDate = startDate
        self.dayCount = max(dayCount, 0)
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PadelDesignTokens.Spacing.s) {
                ForEach(calendarDates, id: \.self) { date in
                    CalendarDayButton(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: currentDate)
                    ) {
                        currentDate = date
                    }
                }
            }
            .padding(.horizontal, PadelDesignTokens.Spacing.xl)
            .padding(.vertical, PadelDesignTokens.Spacing.s)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Calendar")
    }

    private var calendarDates: [Date] {
        let firstDate = calendar.startOfDay(for: startDate)

        return (0..<dayCount).map { offset in
            calendar.date(byAdding: .day, value: offset, to: firstDate) ?? firstDate
        }
    }
}

private struct CalendarDayButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: PadelDesignTokens.Spacing.xxs) {
                Text(weekdayText)
                    .font(PadelDesignTokens.Fonts.footnoteStrong)
                    .foregroundStyle(secondaryForegroundColor)
                    .lineLimit(1)

                Text(dayText)
                    .font(PadelDesignTokens.Fonts.largeTitle)
                    .foregroundStyle(primaryForegroundColor)
                    .lineLimit(1)

                Text(monthText)
                    .font(PadelDesignTokens.Fonts.captionStrong)
                    .foregroundStyle(secondaryForegroundColor)
                    .lineLimit(1)
            }
            .padding(.vertical, PadelDesignTokens.Spacing.l)
            .padding(.horizontal, PadelDesignTokens.Spacing.m)
            .frame(
                width: PadelDesignTokens.Sizing.compactTileWidth,
                height: PadelDesignTokens.Sizing.tallTileHeight
            )
            .background(backgroundColor)
            .clipShape(cellShape)
            .overlay {
                cellShape
                    .stroke(borderColor, lineWidth: PadelDesignTokens.Sizing.hairline)
            }
            .shadow(
                color: PadelDesignTokens.Colors.shadowLow,
                radius: PadelDesignTokens.Shadow.lowRadius,
                x: PadelDesignTokens.Shadow.lowX,
                y: PadelDesignTokens.Shadow.lowY
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityDateText)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var weekdayText: String {
        date.formatted(.dateTime.weekday(.abbreviated)).uppercased()
    }

    private var dayText: String {
        date.formatted(.dateTime.day())
    }

    private var monthText: String {
        date.formatted(.dateTime.month(.abbreviated)).uppercased()
    }

    private var accessibilityDateText: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    private var primaryForegroundColor: Color {
        isSelected ? PadelDesignTokens.Colors.onAccent : PadelDesignTokens.Colors.textPrimary
    }

    private var secondaryForegroundColor: Color {
        isSelected ? PadelDesignTokens.Colors.onAccent : PadelDesignTokens.Colors.textSecondary
    }

    private var backgroundColor: Color {
        isSelected ? PadelDesignTokens.Colors.accent : PadelDesignTokens.Colors.surface
    }

    private var borderColor: Color {
        isSelected ? PadelDesignTokens.Colors.accentPressed : PadelDesignTokens.Colors.borderStrong
    }

    private var cellShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xxl, style: .continuous)
    }
}
