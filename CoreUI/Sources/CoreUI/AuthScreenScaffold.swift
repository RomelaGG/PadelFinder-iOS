//
//  AuthScreenScaffold.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI
import UIKit

// MARK: - AuthScreenScaffold

/// The chassis every auth screen is built on.
///
/// Spacing, the content width cap and the keyboard behaviour live here once, so
/// six screens cannot drift apart from each other one `.padding` at a time.
///
/// The back and close buttons are not here: they live in the navigation bar, via
/// `navBarButton(_:action:)` at the call site, so the whole app shares one
/// implementation of that chrome.
///
/// `title` is optional: Welcome puts a centred brand mark and its own hero
/// block in `content` instead of using the left-aligned title slot.
public struct AuthScreenScaffold<Content: View, Footer: View>: View {
    private let title: String?
    private let subtitle: String?
    private let content: Content
    private let footer: Footer

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.footer = footer()
    }

    public var body: some View {
        ZStack(alignment: .top) {
            PadelDesignTokens.Colors.background
                .ignoresSafeArea()
                .onTapGesture { resignFocus() }

            scrollingBody
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            footerRow
        }
    }
}

// MARK: - Pieces

private extension AuthScreenScaffold {

    var scrollingBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if title != nil || subtitle != nil {
                    titleBlock
                        .padding(.top, PadelDesignTokens.Layout.heroTop)
                        .padding(.bottom, PadelDesignTokens.Layout.sectionGap)
                }

                content
            }
            .frame(maxWidth: PadelDesignTokens.Layout.maxContentWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, PadelDesignTokens.Layout.screenHorizontal)
        }
        .scrollDismissesKeyboard(.interactively)
        .modifier(BounceBasedOnSize())
    }

    @ViewBuilder
    var titleBlock: some View {
        VStack(alignment: .leading, spacing: PadelDesignTokens.Spacing.m) {
            if let title {
                Text(title)
                    .font(PadelDesignTokens.Fonts.display)
                    .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let subtitle {
                Text(subtitle)
                    .font(PadelDesignTokens.Fonts.subheadline)
                    .foregroundStyle(PadelDesignTokens.Colors.textSupport)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var footerRow: some View {
        VStack(spacing: 0) {
            footer
        }
        .frame(maxWidth: PadelDesignTokens.Layout.maxContentWidth)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, PadelDesignTokens.Layout.screenHorizontal)
        .padding(.bottom, PadelDesignTokens.Layout.footerBottom)
        .padding(.top, PadelDesignTokens.Spacing.xl)
    }

    func resignFocus() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - BounceBasedOnSize

/// `.scrollBounceBehavior` arrived in iOS 16.4 and the app ships to 16.0, so
/// the one availability check it needs is kept here rather than at the call
/// site.
private struct BounceBasedOnSize: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.scrollBounceBehavior(.basedOnSize)
        } else {
            content
        }
    }
}

#Preview {
    AuthScreenScaffold(
        title: "Create your account",
        subtitle: "We'll email you a 6-digit code to confirm it's you."
    ) {
        VStack(spacing: PadelDesignTokens.Layout.fieldGap) {
            PadelTextField("Email", text: .constant(""), kind: .email)
            PadelTextField("Password", text: .constant(""), kind: .newPassword)
        }
    } footer: {
        PadelButton("Create account") {}
    }
}
