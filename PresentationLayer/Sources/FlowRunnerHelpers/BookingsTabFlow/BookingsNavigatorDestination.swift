//
//  BookingsNavigatorDestination.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import SwiftUI

/// Empty on purpose: the backend has no booking endpoints at all yet, so there
/// is no booking detail to push to.
enum BookingsNavigatorDestination: NavigatorDestination {
    case none

    @ViewBuilder
    func view() -> some View {
        EmptyView()
    }
}
