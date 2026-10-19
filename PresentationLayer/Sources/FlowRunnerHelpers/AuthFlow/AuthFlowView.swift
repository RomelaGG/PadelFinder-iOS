//
//  AuthFlowView.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import CoreNavigation
import SwiftUI

/// The whole auth flow, in a `fullScreenCover`.
///
/// Welcome is always the root, whatever the entry point, so Back from Sign in
/// lands somewhere sensible rather than closing the flow. A start of `.signIn`
/// or `.signUp` is applied as a push on top of it.
public struct AuthFlowView: View {
    @StateObject private var navigator = Navigator<AuthNavigatorDestination>()
    @State private var hasAppliedStart = false

    private let start: AuthStart

    public init(start: AuthStart) {
        self.start = start
    }

    public var body: some View {
        AuthFlowRunnerFactory().makeView(navigator: navigator)
            .onAppear(perform: applyStart)
    }

    private func applyStart() {
        guard !hasAppliedStart else { return }

        hasAppliedStart = true

        switch start {
        case .welcome:
            break
        case .signIn:
            navigator.push(.signIn(email: nil))
        case .signUp:
            navigator.push(.signUp)
        }
    }
}
