//
//  NavigatorDestination.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 30.05.26.
//

import SwiftUI

public protocol NavigatorDestination: Hashable {
    associatedtype DestinationView: View

    @MainActor
    @ViewBuilder
    func view() -> DestinationView
}
