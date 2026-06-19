//
//  PullRefreshModifier.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 19.06.26.
//

import SwiftUI
import UIKit

private struct PullRefreshModifier: ViewModifier {
    let action: @Sendable () async -> Void

    func body(content: Content) -> some View {
        content
            .refreshable {
                await MainActor.run {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                }

                await action()
            }
    }
}

public extension View {
    func refreshOnPull(perform action: @escaping @Sendable () async -> Void) -> some View {
        modifier(PullRefreshModifier(action: action))
    }
}
