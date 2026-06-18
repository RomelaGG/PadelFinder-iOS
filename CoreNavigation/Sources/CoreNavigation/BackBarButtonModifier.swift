//
//  BackBarButtonModifier.swift
//  CoreNavigation
//
//  Created by Giorgi Romelashvili on 18.06.26.
//

import SwiftUI

public struct BackBarButtonModifier<Destination: NavigatorDestination>: ViewModifier {
    @ObservedObject private var navigator: Navigator<Destination>

    public init(navigator: Navigator<Destination>) {
        self._navigator = ObservedObject(wrappedValue: navigator)
    }

    public func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        navigator.pop()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 38, height: 38)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

public extension View {
    func backBarButton<Destination: NavigatorDestination>(
        navigator: Navigator<Destination>
    ) -> some View {
        modifier(BackBarButtonModifier(navigator: navigator))
    }
}
