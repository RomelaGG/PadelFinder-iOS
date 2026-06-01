//
//  NavigationHost.swift
//  PadelFinder
//
//  Created by Giorgi Romelashvili on 30.05.26.
//

import SwiftUI

struct NavigationHost<RootView: View, Destination: NavigatorDestination>: View {
    @ObservedObject private var navigator: Navigator<Destination>
    private let rootView: () -> RootView

    init(
        navigator: Navigator<Destination>,
        @ViewBuilder rootView: @escaping () -> RootView
    ) {
        self.navigator = navigator
        self.rootView = rootView
    }

    var body: some View {
        NavigationStack(path: $navigator.stack) {
            rootView()
                .navigationDestination(for: Destination.self) { destination in
                    destination.view()
                        .environmentObject(navigator)
                }
                .fullScreenCover(isPresented: $navigator.isPresentedFullScreen) {
                    if let fullScreen = navigator.fullScreen {
                        fullScreen.view()
                            .environment(
                                \.dismissNavigationPresentation,
                                DismissNavigationPresentationAction {
                                    navigator.dismissFullScreen()
                                }
                            )
                            .environmentObject(navigator)
                    }
                }
        }
        .environmentObject(navigator)
    }
}
