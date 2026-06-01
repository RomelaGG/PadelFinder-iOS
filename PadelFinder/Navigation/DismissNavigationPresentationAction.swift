//
//  DismissNavigationPresentationAction.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 30.05.26.
//

import SwiftUI

struct DismissNavigationPresentationAction {
    private let action: () -> Void

    init(_ action: @escaping () -> Void = {}) {
        self.action = action
    }

    func callAsFunction() {
        action()
    }
}

private struct DismissNavigationPresentationKey: EnvironmentKey {
    static let defaultValue = DismissNavigationPresentationAction()
}

extension EnvironmentValues {
    var dismissNavigationPresentation: DismissNavigationPresentationAction {
        get { self[DismissNavigationPresentationKey.self] }
        set { self[DismissNavigationPresentationKey.self] = newValue }
    }
}
