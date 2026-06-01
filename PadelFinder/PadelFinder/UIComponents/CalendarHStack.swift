//
//  CalendarHStack.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 31.05.26.
//

import SwiftUI

struct CalendarHStack: View {
    @Binding var currentDate: Date

    private let calendar: Calendar
    private let dayCount: Int

    init(
        currentDate: Binding<Date>,
        calendar: Calendar = .current,
        dayCount: Int = PadelDesignTokens.CalendarLayout.visibleDayCount
    ) {
        self._currentDate = currentDate
        self.calendar = calendar
        self.dayCount = max(dayCount, 0)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PadelDesignTokens.Spacing.calendarItem) {
                ForEach(calendarDates, id: \.self) { date in
                    CalendarDayButton(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: currentDate)
                    ) {
                        currentDate = date
                    }
                }
            }
            .padding(.horizontal, PadelDesignTokens.Spacing.calendarHorizontalInset)
            .padding(.vertical, PadelDesignTokens.Spacing.calendarShadowVerticalInset)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Calendar")
    }

    private var calendarDates: [Date] {
        let startDate = calendar.startOfDay(for: Date())

        return (0..<dayCount).map { offset in
            calendar.date(byAdding: .day, value: offset, to: startDate) ?? startDate
        }
    }
}

private struct CalendarDayButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: PadelDesignTokens.Spacing.calendarCellContent) {
                Text(weekdayText)
                    .font(PadelDesignTokens.Fonts.calendarWeekday)
                    .foregroundStyle(secondaryForegroundColor)
                    .lineLimit(1)

                Text(dayText)
                    .font(PadelDesignTokens.Fonts.calendarDay)
                    .foregroundStyle(primaryForegroundColor)
                    .lineLimit(1)

                Text(monthText)
                    .font(PadelDesignTokens.Fonts.calendarMonth)
                    .foregroundStyle(secondaryForegroundColor)
                    .lineLimit(1)
            }
            .padding(.vertical, PadelDesignTokens.Spacing.calendarCellVertical)
            .padding(.horizontal, PadelDesignTokens.Spacing.calendarCellHorizontal)
            .frame(
                width: PadelDesignTokens.Sizing.calendarCellWidth,
                height: PadelDesignTokens.Sizing.calendarCellHeight
            )
            .background(backgroundColor)
            .clipShape(calendarCellShape)
            .overlay {
                calendarCellShape
                    .stroke(borderColor, lineWidth: PadelDesignTokens.Sizing.calendarCellBorderWidth)
            }
            .shadow(
                color: PadelDesignTokens.Colors.calendarCellShadow,
                radius: PadelDesignTokens.Shadow.calendarCellRadius,
                x: PadelDesignTokens.Shadow.calendarCellX,
                y: PadelDesignTokens.Shadow.calendarCellY
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
        isSelected ? PadelDesignTokens.Colors.selectedText : PadelDesignTokens.Colors.textPrimary
    }

    private var secondaryForegroundColor: Color {
        isSelected ? PadelDesignTokens.Colors.selectedText : PadelDesignTokens.Colors.textSecondary
    }

    private var backgroundColor: Color {
        isSelected ? PadelDesignTokens.Colors.courtGreen : PadelDesignTokens.Colors.surface
    }

    private var borderColor: Color {
        isSelected ? PadelDesignTokens.Colors.courtGreenPressed : PadelDesignTokens.Colors.border
    }

    private var calendarCellShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.calendarCell, style: .continuous)
    }
}
