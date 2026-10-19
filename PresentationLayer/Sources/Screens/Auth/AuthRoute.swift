//
//  AuthRoute.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import SwiftUI

// MARK: - AuthRoute

/// Where a view model wants the flow to go next.
///
/// View models cannot navigate — the navigator lives in the view's
/// environment — so each one parks a route in its state and the view acts on
/// it. One shared modifier does the acting, so six screens do not each grow
/// their own `onChange` block.
enum AuthRoute: Equatable {
    case push(AuthNavigatorDestination)

    /// Replaces the whole stack. Used after a code has been spent, so Back
    /// cannot walk the user onto a dead one.
    case replace(AuthNavigatorDestination)

    case dismissFlow

    /// Back one step. "Wrong email? Change it" uses this to land on the form
    /// the address was typed into. Safe unconditionally: the screens that ask
    /// for it are never the flow's root.
    case pop
}

// MARK: - authRouting

extension View {
    /// Acts on a view model's pending route, then tells it the route was
    /// handled so the same push cannot fire twice.
    func authRouting(_ route: AuthRoute?, onHandled: @escaping () -> Void) -> some View {
        modifier(AuthRoutingModifier(route: route, onHandled: onHandled))
    }
}

private struct AuthRoutingModifier: ViewModifier {
    @EnvironmentObject private var navigator: Navigator<AuthNavigatorDestination>
    @EnvironmentObject private var presenter: AuthPresenter

    let route: AuthRoute?
    let onHandled: () -> Void

    func body(content: Content) -> some View {
        content.onChange(of: route) { route in
            guard let route else { return }

            switch route {
            case let .push(destination):
                navigator.push(destination)

            case let .replace(destination):
                navigator.replaceStack(with: destination)

            case .dismissFlow:
                presenter.dismissFlow()

            case .pop:
                navigator.pop()
            }

            onHandled()
        }
    }
}
