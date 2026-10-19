//
//  AccountFlowView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import SwiftUI

public struct AccountFlowView: View {
    @StateObject private var navigator = Navigator<AccountNavigatorDestination>()

    public init() { }

    public var body: some View {
        AccountFlowRunnerFactory().makeView(navigator: navigator)
    }
}
