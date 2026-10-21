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

    /// Zero when the footer slot is empty — `VerifyCode` leaves it so for the
    /// password-reset purpose — which is how the bar knows not to draw itself.
    @State private var footerContentHeight: CGFloat = 0
    @State private var isKeyboardVisible = false

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
        .onReceive(keyboardWillShow) { _ in isKeyboardVisible = true }
        .onReceive(keyboardWillHide) { _ in isKeyboardVisible = false }
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
        .background(HeightReader(height: $footerContentHeight))
        .padding(.horizontal, PadelDesignTokens.Layout.screenHorizontal)
        .padding(.bottom, bottomInset)
        .padding(.top, PadelDesignTokens.Spacing.xl)
        .environment(\.isKeyboardVisible, isKeyboardVisible)
        // Only the *background* is conditional, never the frame or the padding:
        // feeding a measured height back into layout inside a `safeAreaInset`
        // is how a resize loop starts.
        .background { if footerContentHeight > 0 { footerBackground } }
        .animation(.easeOut(duration: PadelDesignTokens.Motion.fast), value: isKeyboardVisible)
    }

    /// The bar the footer floats on, so the form passing underneath blurs away
    /// instead of showing through the gaps between the buttons.
    ///
    /// It bleeds past the bottom of the container — but never past the keyboard —
    /// because the scroll view runs under the home indicator even though the
    /// footer stops above it.
    var footerBackground: some View {
        Color.clear
            .padelGlass(in: Rectangle())
            .overlay(alignment: .top) {
                PadelDesignTokens.Colors.border
                    .frame(height: PadelDesignTokens.Sizing.hairline)
            }
            .ignoresSafeArea(.container, edges: .bottom)
    }

    /// `footerBottom` clears the home indicator. The keyboard covers it, so with
    /// the keyboard up that gap is height the squeezed form could be using.
    var bottomInset: CGFloat {
        isKeyboardVisible
            ? PadelDesignTokens.Layout.footerBottomCompact
            : PadelDesignTokens.Layout.footerBottom
    }

    var keyboardWillShow: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
    }

    var keyboardWillHide: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
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

// MARK: - isKeyboardVisible

private struct IsKeyboardVisibleKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    /// Whether the keyboard is on screen, published by `AuthScreenScaffold` to
    /// everything in its footer.
    ///
    /// The footer is built at the call site but rendered in here, so a footer
    /// that wants to change shape with the keyboard — a full-width button that
    /// becomes a compact one — can read this instead of every auth screen
    /// growing its own notification observer.
    var isKeyboardVisible: Bool {
        get { self[IsKeyboardVisibleKey.self] }
        set { self[IsKeyboardVisibleKey.self] = newValue }
    }
}

// MARK: - HeightReader

/// Reports the height of the view it backs.
///
/// Installed as a background so it measures without taking part in the layout
/// it is measuring, and defers the report off SwiftUI's update pass.
private struct HeightReader: View {
    @Binding var height: CGFloat

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { report(proxy.size.height) }
                .onChange(of: proxy.size.height) { report($0) }
        }
    }

    private func report(_ newHeight: CGFloat) {
        guard height != newHeight else { return }

        Task { @MainActor in
            height = newHeight
        }
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
