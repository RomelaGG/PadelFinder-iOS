//
//  BookingsView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreUI
import DesignSystem
import DomainLayer
import SwiftUI

struct BookingsView: View {
    @StateObject private var viewModel: BookingsViewModel
    @EnvironmentObject private var authSession: AuthSession
    @EnvironmentObject private var presenter: AuthPresenter

    init(viewModel: BookingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: PadelDesignTokens.Layout.sectionGap) {
            Text(AuthCopy.Bookings.title)
                .font(PadelDesignTokens.Fonts.display)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, PadelDesignTokens.Layout.heroTop)

            Spacer(minLength: 0)

            content

            Spacer(minLength: 0)
        }
        .padding(.horizontal, PadelDesignTokens.Layout.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PadelDesignTokens.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    /// An empty list is the wrong thing to show somebody with no account - it
    /// says "you have nothing" when the truth is "we do not know you yet".
    @ViewBuilder
    private var content: some View {
        switch authSession.state {
        case .unknown:
            PadelStateView(.loading)

        case .signedOut:
            VStack(spacing: PadelDesignTokens.Layout.sectionGap) {
                PadelStateView(
                    .empty(
                        icon: "calendar.badge.plus",
                        title: AuthCopy.Bookings.emptyTitle,
                        message: AuthCopy.Bookings.emptySignedOut
                    )
                )

                PadelButton(AuthCopy.Common.signIn) {
                    presenter.presentFlow(.welcome)
                }
            }

        case .signedIn:
            PadelStateView(
                .empty(
                    icon: "calendar.badge.plus",
                    title: AuthCopy.Bookings.emptyTitle,
                    message: AuthCopy.Bookings.emptySignedIn
                )
            )
        }
    }
}
