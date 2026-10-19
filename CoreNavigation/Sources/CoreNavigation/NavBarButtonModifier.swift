//
//  NavBarButtonModifier.swift
//  CoreNavigation
//
//  Created by Giorgi Romelashvili on 18.06.26.
//

import DesignSystem
import SwiftUI
import UIKit

// MARK: - NavBarButtonRole

/// Which affordance the bar carries.
public enum NavBarButtonRole {
    /// Pops the stack. iOS 26 has a native one worth deferring to.
    case back

    /// Leaves the flow. No iOS version offers a system item for this, so it is
    /// always ours.
    case close
}

// MARK: - NavBarButtonModifier

/// The nav chrome for a screen whose content runs under the bar.
///
/// On iOS 26 `.back` does nothing on purpose: the system back item already sits
/// in a Liquid Glass bar that fades in as content scrolls, and it reads well
/// over a photo. Anything we put there instead would be a downgrade.
///
/// Below 26 that same item is a bare chevron and label with no background, so
/// the bar keeps its layout but loses its blur, and the item becomes the house
/// glass circle.
///
/// `.close` has no system counterpart, so it is drawn on every version — iOS 26
/// renders a `ToolbarItem` in glass by itself.
public struct NavBarButtonModifier: ViewModifier {
    private let role: NavBarButtonRole
    private let action: () -> Void

    public init(role: NavBarButtonRole, action: @escaping () -> Void) {
        self.role = role
        self.action = action
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        switch role {
        case .back:
            backBody(content)

        case .close:
            closeBody(content)
        }
    }
}

// MARK: - Bodies

private extension NavBarButtonModifier {
    @ViewBuilder
    func backBody(_ content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        button
                    }
                }
                // The bar has to stay in place for its items to render — only its
                // background goes, so whatever is behind shows through.
                .toolbarBackground(.hidden, for: .navigationBar)
                .restoringSwipeBack()
        }
    }

    @ViewBuilder
    func closeBody(_ content: Content) -> some View {
        let content = content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    button
                }
            }

        if #available(iOS 26.0, *) {
            // Left alone so the bar behaves like every other screen on 26: the
            // item comes up in glass, and the background fades in on scroll.
            content
        } else {
            content
                .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    var button: some View {
        Button {
            resignFocus()

            action()
        } label: {
            Image(systemName: role.systemImage)
                .font(PadelDesignTokens.Fonts.callout)
                .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
                .frame(
                    width: PadelDesignTokens.Sizing.compactControlHeight,
                    height: PadelDesignTokens.Sizing.compactControlHeight
                )
                .padelGlass(in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(role.accessibilityLabel)
    }

    /// Forms hand the keyboard back before the screen leaves, so it does not
    /// outlive the transition.
    func resignFocus() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Role traits

private extension NavBarButtonRole {
    var systemImage: String {
        switch self {
        case .back: "chevron.left"
        case .close: "xmark"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .back: "Back"
        case .close: "Close"
        }
    }
}

// MARK: - View

public extension View {
    func navBarButton(_ role: NavBarButtonRole, action: @escaping () -> Void) -> some View {
        modifier(NavBarButtonModifier(role: role, action: action))
    }

    /// Sugar for the common case: a back button that pops this navigator.
    func backBarButton<Destination: NavigatorDestination>(
        navigator: Navigator<Destination>
    ) -> some View {
        navBarButton(.back) {
            navigator.pop()
        }
    }
}
