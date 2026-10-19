//
//  AccountView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreUI
import DesignSystem
import DomainLayer
import SwiftUI

/// The findable front door.
///
/// A tab, not a button hidden in a corner: a sign-in that only ever appears as
/// an interruption is a sign-in nobody can find on purpose.
struct AccountView: View {
    @StateObject private var viewModel: AccountViewModel
    @EnvironmentObject private var authSession: AuthSession
    @EnvironmentObject private var presenter: AuthPresenter

    init(viewModel: AccountViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: PadelDesignTokens.Layout.sectionGap) {
                header

                content
            }
            .padding(.horizontal, PadelDesignTokens.Layout.screenHorizontal)
            .padding(.bottom, PadelDesignTokens.Layout.sectionGap)
        }
        .background(PadelDesignTokens.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(
            AuthCopy.Account.signOutConfirm,
            isPresented: signOutDialogBinding,
            titleVisibility: .visible
        ) {
            Button(AuthCopy.Account.rowSignOut, role: .destructive) {
                viewModel.handleIntent(.signOutConfirmed)
            }

            Button(AuthCopy.Common.cancel, role: .cancel) { }
        }
        .alert(
            AuthCopy.Account.deleteConfirmTitle,
            isPresented: deleteAlertBinding
        ) {
            Button(AuthCopy.Account.rowDelete, role: .destructive) {
                viewModel.handleIntent(.deleteAccountConfirmed)
            }

            Button(AuthCopy.Common.cancel, role: .cancel) { }
        } message: {
            Text(AuthCopy.Account.deleteConfirmMessage)
        }
        .padelLoadingOverlay(viewModel.state.isDeleting)
    }
}

// MARK: - Pieces

private extension AccountView {

    var header: some View {
        Text(AuthCopy.Account.title)
            .font(PadelDesignTokens.Fonts.display)
            .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, PadelDesignTokens.Layout.heroTop)
    }

    @ViewBuilder
    var content: some View {
        switch authSession.state {
        case .unknown:
            // The Keychain read has not finished. Showing the promo card here
            // would flash "you are signed out" at somebody who is signed in.
            PadelStateView(.loading)

        case .signedOut:
            signedOut

        case let .signedIn(user):
            signedIn(user)
        }
    }

    // MARK: Signed out

    var signedOut: some View {
        VStack(spacing: PadelDesignTokens.Layout.sectionGap) {
            promoCard

            PadelListCard(informationRows)

            versionLabel
        }
    }

    var promoCard: some View {
        VStack(spacing: 0) {
            PadelBrandMark()

            Text(AuthCopy.Account.promoTitle)
                .font(PadelDesignTokens.Fonts.title)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                .padding(.top, PadelDesignTokens.Spacing.xxxl)

            Text(AuthCopy.Account.promoBody)
                .font(PadelDesignTokens.Fonts.body)
                .foregroundStyle(PadelDesignTokens.Colors.textSupport)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, PadelDesignTokens.Spacing.m)

            PadelButton(AuthCopy.Account.promoCTA) {
                presenter.presentFlow(.welcome)
            }
            .padding(.top, PadelDesignTokens.Layout.sectionGap)
        }
        .padding(PadelDesignTokens.Spacing.xxxl)
        .frame(maxWidth: .infinity)
        .background(PadelDesignTokens.Colors.surface)
        .clipShape(cardShape)
        .overlay {
            cardShape.stroke(
                PadelDesignTokens.Colors.border,
                lineWidth: PadelDesignTokens.Sizing.hairline
            )
        }
        .shadow(
            color: PadelDesignTokens.Colors.shadowRaised,
            radius: PadelDesignTokens.Shadow.raisedRadius,
            x: PadelDesignTokens.Shadow.raisedX,
            y: PadelDesignTokens.Shadow.raisedY
        )
    }

    // MARK: Signed in

    func signedIn(_ user: AuthUser) -> some View {
        VStack(spacing: PadelDesignTokens.Layout.fieldGap) {
            identityRow(user)
                .padding(.bottom, PadelDesignTokens.Spacing.xl)

            if let message = viewModel.state.bannerMessage {
                PadelInlineBanner(message)
            }

            PadelListCard(bookingRows)

            PadelListCard(informationRows)

            PadelListCard(dangerRows)

            versionLabel
        }
    }

    func identityRow(_ user: AuthUser) -> some View {
        HStack(spacing: PadelDesignTokens.Spacing.xxxl) {
            AvatarView(imageURL: nil, initials: user.initials, size: .large)

            VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.xs) {
                Text(user.title)
                    .font(PadelDesignTokens.Fonts.title)
                    .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                // Omitted when the title is already the email - there is no
                // point printing the same string twice.
                if let subtitle = user.subtitle {
                    Text(subtitle)
                        .font(PadelDesignTokens.Fonts.body)
                        .foregroundStyle(PadelDesignTokens.Colors.textSupport)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Rows
    //
    // Rows with no `action` are drawn but not tappable. Nothing stands behind
    // bookings, payments, notifications, language or help yet - the backend
    // has no endpoints for any of them - and a row that highlights and then
    // does nothing is a worse promise than one that never looked tappable.

    var bookingRows: [PadelListRow] {
        [
            PadelListRow(icon: "calendar", title: AuthCopy.Account.rowBookings),
            PadelListRow(icon: "creditcard", title: AuthCopy.Account.rowPayment),
            PadelListRow(icon: "bell", title: AuthCopy.Account.rowNotifications)
        ]
    }

    var informationRows: [PadelListRow] {
        [
            PadelListRow(
                icon: "globe",
                title: AuthCopy.Account.rowLanguage,
                accessory: .value(AuthCopy.Account.rowLanguageValue)
            ),
            PadelListRow(icon: "questionmark.circle", title: AuthCopy.Account.rowHelp),
            PadelListRow(icon: "doc.text", title: AuthCopy.Common.terms),
            PadelListRow(icon: "hand.raised", title: AuthCopy.Common.privacy)
        ]
    }

    /// No chevrons: a chevron promises navigation, and both of these act
    /// immediately.
    var dangerRows: [PadelListRow] {
        [
            PadelListRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: AuthCopy.Account.rowSignOut,
                accessory: .none,
                isDestructive: true,
                action: { viewModel.handleIntent(.signOutTapped) }
            ),
            PadelListRow(
                icon: "trash",
                title: AuthCopy.Account.rowDelete,
                accessory: .none,
                isDestructive: true,
                action: { viewModel.handleIntent(.deleteAccountTapped) }
            )
        ]
    }

    var versionLabel: some View {
        Text(versionText)
            .font(PadelDesignTokens.Fonts.caption)
            .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, PadelDesignTokens.Spacing.xxxl)
    }

    var versionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"

        return "PadelFinder \(version) (\(build))"
    }

    var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xxxl, style: .continuous)
    }

    // MARK: Bindings

    var signOutDialogBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.isSignOutDialogPresented },
            set: { if !$0 { viewModel.handleIntent(.dialogDismissed) } }
        )
    }

    var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.isDeleteAlertPresented },
            set: { if !$0 { viewModel.handleIntent(.alertDismissed) } }
        )
    }
}
