//
//  FormBindable.swift
//  PresentationLayer
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import SwiftUI

// MARK: - FormBindable

/// Lets a `TextField` write into a view model whose state is `private(set)`.
///
/// The existing view models expose `@Published private(set) var state`, which
/// a two-way binding cannot write to. The alternative - keeping each field in
/// the view's own `@State` - would take normalising and clearing away from the
/// view model, which is exactly where trimming an email or wiping a password
/// after a failed sign-in belongs.
///
/// So reads come from the state and writes go through an intent. State stays
/// `private(set)` and intents stay the only way anything changes.
@MainActor
protocol FormBindable: AnyObject {
    associatedtype State
    associatedtype Intent

    var state: State { get }

    func handleIntent(_ intent: Intent)
}

extension FormBindable {
    func binding<Value>(
        _ keyPath: KeyPath<State, Value>,
        _ intent: @escaping (Value) -> Intent
    ) -> Binding<Value> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { self.handleIntent(intent($0)) }
        )
    }
}
