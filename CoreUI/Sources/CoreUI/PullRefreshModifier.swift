//
//  PullRefreshModifier.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 19.06.26.
//

import SwiftUI
import UIKit

// MARK: - PullRefreshModifier

/// Pull-to-refresh that keeps the scroll content in place.
///
/// The system `refreshable` control inserts empty space at the top of the scroll
/// view while it spins, which tears a gap above full-bleed content. Here the
/// indicator is drawn as an overlay instead, so nothing ever moves: it fades in
/// with the pull and sits on top of whatever the scroll view already shows.
@MainActor
private struct PullRefreshModifier: ViewModifier {
    let action: @Sendable () async -> Void

    @State private var pullDistance: CGFloat = 0
    @State private var isArmed = false
    @State private var isRefreshing = false

    func body(content: Content) -> some View {
        content
            .background(
                ScrollOverscrollReader { distance, isTracking in
                    pullDistance = distance

                    if isTracking {
                        armIfNeeded(at: distance)
                    } else {
                        startRefreshIfArmed()
                    }
                }
            )
            .overlay(alignment: .top) { indicator }
    }
}

// MARK: - Indicator

private extension PullRefreshModifier {
    enum Constants {
        static let triggerDistance: CGFloat = 90
        static let indicatorPadding: CGFloat = 10
        static let indicatorTopSpacing: CGFloat = 12
        static let minimumScale: CGFloat = 0.7
    }

    /// How far the pull has travelled towards triggering a refresh, `0...1`.
    var pullProgress: CGFloat {
        min(max(pullDistance / Constants.triggerDistance, 0), 1)
    }

    var indicator: some View {
        GeometryReader { proxy in
            ProgressView()
                .progressViewStyle(.circular)
                .padding(Constants.indicatorPadding)
                .background(.ultraThinMaterial, in: Circle())
                .scaleEffect(isRefreshing ? 1 : Constants.minimumScale + (1 - Constants.minimumScale) * pullProgress)
                .opacity(isRefreshing ? 1 : pullProgress)
                .frame(maxWidth: .infinity)
                .padding(.top, topInset(in: proxy) + Constants.indicatorTopSpacing)
        }
        .allowsHitTesting(false)
    }

    /// Keeps the indicator clear of the status bar / dynamic island when the
    /// scroll view itself extends underneath them.
    func topInset(in proxy: GeometryProxy) -> CGFloat {
        max(0, safeAreaTopInset - proxy.frame(in: .global).minY)
    }

    var safeAreaTopInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .keyWindow?
            .safeAreaInsets.top ?? 0
    }
}

// MARK: - Refreshing

private extension PullRefreshModifier {
    func armIfNeeded(at distance: CGFloat) {
        guard !isArmed, !isRefreshing, distance >= Constants.triggerDistance else { return }

        isArmed = true

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    func startRefreshIfArmed() {
        guard isArmed else { return }

        isArmed = false
        withAnimation(.easeOut(duration: 0.2)) { isRefreshing = true }

        Task {
            await action()
            withAnimation(.easeOut(duration: 0.2)) { isRefreshing = false }
        }
    }
}

// MARK: - View

public extension View {
    /// Pull-to-refresh whose indicator overlays the content instead of pushing it down.
    func refreshOnPull(perform action: @escaping @Sendable () async -> Void) -> some View {
        modifier(PullRefreshModifier(action: action))
    }
}
