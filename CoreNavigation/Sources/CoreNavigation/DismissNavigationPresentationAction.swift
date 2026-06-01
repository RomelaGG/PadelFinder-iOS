//
//  DismissNavigationPresentationAction.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 30.05.26.
//

import SwiftUI

public struct DismissNavigationPresentationAction: Sendable {
    private let action: @MainActor @Sendable () -> Void

    public init(_ action: @escaping @MainActor @Sendable () -> Void = {}) {
        self.action = action
    }

    @MainActor
    func callAsFunction() {
        action()
    }
}

private struct DismissNavigationPresentationKey: Sendable, EnvironmentKey {
    static let defaultValue = DismissNavigationPresentationAction()
}

public extension EnvironmentValues {
    var dismissNavigationPresentation: DismissNavigationPresentationAction {
        get { self[DismissNavigationPresentationKey.self] }
        set { self[DismissNavigationPresentationKey.self] = newValue }
    }
}
