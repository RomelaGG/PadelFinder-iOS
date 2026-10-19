//
//  AccountNavigatorDestination.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import SwiftUI

/// Nothing to push yet: of the Account rows, only Sign out and Delete account
/// do anything, and both act in place rather than navigating. The destination
/// type exists so the tab has a `NavigationHost` to grow into.
enum AccountNavigatorDestination: NavigatorDestination {
    case none

    @ViewBuilder
    func view() -> some View {
        EmptyView()
    }
}
