//
//  ClubDetailsView.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 17.06.26.
//

import SwiftUI
import CoreNavigation
import CoreUI
import DesignSystem

// MARK: - ClubDetailsView

struct ClubDetailsView: View {
    @EnvironmentObject var navigator: Navigator<PadelCourtsTabNavigatorDestination>
    @StateObject var viewModel: ClubDetailsViewModel
    @State private var currentDate: Date

    init(viewModel: ClubDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._currentDate = State(initialValue: viewModel.state.initialDate)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                hero

                identity
                    .padding(.top, PadelDesignTokens.Spacing.xxxl)

                selectDaySection
                    .padding(.top, PadelDesignTokens.Spacing.xxxxl)

                availableTimeSection
                    .padding(.top, PadelDesignTokens.Spacing.xxxxl)

                courtsSection
                    .padding(.top, PadelDesignTokens.Spacing.xxxl)
                    .padding(.bottom, PadelDesignTokens.Spacing.xxxl)
            }
        }
        .background(PadelDesignTokens.Colors.background.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.handleIntent(.loadAvailability(currentDate))
        }
        .onChange(of: currentDate) { newDate in
            viewModel.handleIntent(.loadAvailability(newDate))
        }
    }
}

// MARK: - Hero

private extension ClubDetailsView {
    var hero: some View {
        GeometryReader { geo in
            let offsetY = geo.frame(in: .global).minY
            let isScrolledDown = offsetY > 0

            ZStack(alignment: .topLeading) {
                // Parallax image — grows and stays pinned on over-scroll
                Group {
                    coverImage
                }
                .frame(
                    width: geo.size.width,
                    height: isScrolledDown ? 200 + offsetY : 200  // grows on pull-down
                )
                .clipped()
                .offset(y: isScrolledDown ? -offsetY : 0)  // pins to top on pull-down

                backButton
                    .padding(.leading, PadelDesignTokens.Spacing.xxxl)
                    .padding(.top, 54)
            }
        }
        .frame(height: 200)  // reserves fixed space in the layout
    }

    @ViewBuilder
    var coverImage: some View {
        if let imageURL = viewModel.state.coverImageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    coverPlaceholder
                }
            }
        } else {
            coverPlaceholder
        }
    }

    var coverPlaceholder: some View {
        LinearGradient(
            colors: [PadelDesignTokens.Colors.accent, PadelDesignTokens.Colors.accentPressed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var backButton: some View {
        Button {
            navigator.pop()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                .frame(width: 38, height: 38)
                .background(.ultraThinMaterial, in: Circle())
        }
        .accessibilityLabel("Back")
    }
}

// MARK: - Identity

private extension ClubDetailsView {
    var identity: some View {
        HStack(alignment: .center, spacing: PadelDesignTokens.Spacing.xxl) {
            CompanyLogo(
                logoURL: viewModel.state.logoURL,
                title: viewModel.state.logoTitle,
                backgroundColor: viewModel.state.logoBackground,
                foregroundColor: viewModel.state.logoForeground,
                lineColor: viewModel.state.logoLine
            )

            VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xs) {
                Text(viewModel.state.headerTitle)
                    .font(PadelDesignTokens.Fonts.title)
                    .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                HStack(spacing: PadelDesignTokens.Spacing.s) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(PadelDesignTokens.Colors.textSecondary)

                    Text(viewModel.state.location)
                        .font(PadelDesignTokens.Fonts.body)
                        .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
    }
}

// MARK: - Sections

private extension ClubDetailsView {
    var selectDaySection: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.m) {
            sectionLabel("Select day")

            CalendarHStack(
                currentDate: $currentDate,
                startDate: Calendar.current.startOfDay(for: Date()),
                dayCount: 21
            )
        }
    }

    @ViewBuilder
    var availableTimeSection: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.m) {
            sectionLabel("Available time")

            content(
                isEmpty: viewModel.state.slots.isEmpty,
                emptyText: "No times available for this day."
            ) {
                SlotPillsRow(slots: viewModel.state.slots)
            }
        }
    }

    @ViewBuilder
    var courtsSection: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xxl) {
            sectionLabel(courtsSectionTitle)

            content(
                isEmpty: viewModel.state.courts.isEmpty,
                emptyText: "No courts available for this day."
            ) {
                LazyVStack(spacing: PadelDesignTokens.Spacing.xxl) {
                    ForEach(viewModel.state.courts) { court in
                        courtCard(court)
                    }
                }
            }
        }
    }

    var courtsSectionTitle: String {
        viewModel.state.courts.isEmpty ? "All courts" : "All courts · \(viewModel.state.courts.count)"
    }

    func courtCard(_ court: ClubCourtRowModel) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: PadelDesignTokens.Spacing.xl) {
                VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xxs) {
                    Text(court.name)
                        .font(PadelDesignTokens.Fonts.bodyStrong)
                        .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                        .lineLimit(1)

                    if let price = court.pricePerHour {
                        Text("from \(price) ₾ / hour")
                            .font(PadelDesignTokens.Fonts.body)
                            .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(court.freeCount) free")
                    .font(PadelDesignTokens.Fonts.captionStrong)
                    .foregroundStyle(PadelDesignTokens.Colors.accent)
            }
            .padding(.horizontal, PadelDesignTokens.Spacing.xxl)
            .padding(.top, PadelDesignTokens.Spacing.xxl)
            .padding(.bottom, PadelDesignTokens.Spacing.xl)

            Divider()
                .overlay(PadelDesignTokens.Colors.border)
                .padding(.horizontal, PadelDesignTokens.Spacing.xxl)

            SlotPillsRow(slots: court.slots, size: .compact)
                .padding(.vertical, PadelDesignTokens.Spacing.l)
        }
        .background(PadelDesignTokens.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xl, style: .continuous)
                .stroke(PadelDesignTokens.Colors.border, lineWidth: PadelDesignTokens.Sizing.hairline)
        }
        .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
    }
}

// MARK: - Shared helpers

private extension ClubDetailsView {
    func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(PadelDesignTokens.Fonts.captionStrong)
            .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
            .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
    }

    @ViewBuilder
    func content<Loaded: View>(
        isEmpty: Bool,
        emptyText: String,
        @ViewBuilder loaded: () -> Loaded
    ) -> some View {
        if viewModel.state.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 80)
        } else if let errorMessage = viewModel.state.errorMessage {
            Text(errorMessage)
                .font(PadelDesignTokens.Fonts.body)
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
        } else if isEmpty {
            Text(emptyText)
                .font(PadelDesignTokens.Fonts.body)
                .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding(.horizontal, PadelDesignTokens.Spacing.xxxl)
        } else {
            loaded()
        }
    }
}
