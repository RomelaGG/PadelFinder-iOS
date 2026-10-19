//
//  BookingsFlowView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import SwiftUI

public struct BookingsFlowView: View {
    @StateObject private var navigator = Navigator<BookingsNavigatorDestination>()

    public init() { }

    public var body: some View {
        BookingsFlowRunnerFactory().makeView(navigator: navigator)
    }
}
