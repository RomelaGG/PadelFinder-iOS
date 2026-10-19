//
//  PadelFinderTabView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreDI
import CoreUI
import DesignSystem
import DomainLayer
import SwiftUI
import UIKit

// MARK: - PadelTab

/// Named `PadelTab` rather than `Tab`: SwiftUI has its own `Tab` type in
/// scope, and the collision is the kind that produces an error three files
/// away from the cause.
public enum PadelTab: Hashable {
    case explore
    case bookings
    case account
}

// MARK: - PendingBookingAccessory

/// The slot a player has chosen but not yet booked.
struct PendingBookingAccessory: Equatable {
    let clubName: String
    let time: String
    let price: String
}

// MARK: - PadelFinderTabView

/// The app's root.
///
/// A tab bar rather than a profile button in a corner, for two reasons: a tab
/// is the only entry point a user can find on purpose, and "My bookings" needs
/// a home it can grow into. Browsing is never gated - nothing in Explore asks
/// for an account.
public struct PadelFinderTabView: View {
    @StateObject private var presenter: AuthPresenter
    @StateObject private var authSession: AuthSession
    @State private var selectedTab: PadelTab = .explore
    @State private var pendingBooking: PendingBookingAccessory?

    public init() {
        _presenter = StateObject(wrappedValue: AppDependency.shared.resolve(AuthPresenter.self))
        _authSession = StateObject(wrappedValue: AppDependency.shared.resolve(AuthSession.self))

        // The ONLY place an appearance proxy may be installed, and only below
        // iOS 26. On 26 the bar is Liquid Glass for free, and setting an
        // appearance is precisely what throws that away.
        if #unavailable(iOS 26.0) {
            Self.configureOpaqueTabBarAppearance()
        }
    }

    public var body: some View {
        tabs
            .tint(PadelDesignTokens.Colors.accent)
            .preferredColorScheme(.light)
            .environmentObject(presenter)
            .environmentObject(authSession)
            .sheet(
                item: presenter.gateBinding,
                onDismiss: presenter.presentPendingFlowIfNeeded
            ) { gate in
                SignInGateSheet(reason: gate.reason)
                    .environmentObject(presenter)
            }
            .fullScreenCover(item: presenter.flowBinding) { flow in
                AuthFlowView(start: flow.start)
                    .environmentObject(presenter)
                    .environmentObject(authSession)
            }
    }
}

// MARK: - Pieces

private extension PadelFinderTabView {

    /// The accessory is attached only when there is something to put in it.
    ///
    /// Returning `EmptyView()` from `tabViewBottomAccessory` does **not** hide
    /// it: iOS 26.0 still reserves the slot, draws an empty glass capsule
    /// above the tab bar, and lets that capsule swallow taps aimed at the tab
    /// bar underneath. The `isEnabled:` overload that would say this properly
    /// is 26.1 only, so the modifier is simply not applied until a booking is
    /// pending.
    @ViewBuilder
    var tabs: some View {
        if let pendingBooking {
            accessorised(baseTabs, booking: pendingBooking)
        } else {
            baseTabs
        }
    }

    @ViewBuilder
    func accessorised(_ tabs: some View, booking: PendingBookingAccessory) -> some View {
        if #available(iOS 26.0, *) {
            tabs.tabViewBottomAccessory { pill(for: booking) }
        } else {
            tabs.overlay(alignment: .bottom) { pill(for: booking) }
        }
    }

    var baseTabs: some View {
        TabView(selection: $selectedTab) {
            PadelCourtsTabFlowView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(PadelTab.explore)

            BookingsFlowView()
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }
                .tag(PadelTab.bookings)

            AccountFlowView()
                .tabItem {
                    // No badge when signed out: a red dot implies a problem
                    // the user has not actually got.
                    Label("Account", systemImage: "person.crop.circle")
                }
                .tag(PadelTab.account)
        }
    }

    /// Carries the slot a player tapped above the tab bar, so a chosen court
    /// survives navigation. Nothing sets `pendingBooking` yet — booking is a
    /// later phase, and the backend has no booking endpoints at all.
    func pill(for booking: PendingBookingAccessory) -> some View {
        BookingAccessoryPill(
            clubName: booking.clubName,
            time: booking.time,
            price: booking.price,
            onTap: { }
        )
    }

    static func configureOpaqueTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(PadelDesignTokens.Colors.surface)
        appearance.shadowColor = UIColor(PadelDesignTokens.Colors.border)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
