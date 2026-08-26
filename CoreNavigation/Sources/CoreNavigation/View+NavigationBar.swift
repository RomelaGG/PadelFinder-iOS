//
//  View+NavigationBar.swift
//  PresentationCashback
//
//  Created by Giorgi Romelashvili on 26.08.26.
//

import UIKit
import SwiftUI

// MARK: - hidingNavigationBar

extension View {
    /// Hides the parent PBNavigationStack's bar so this screen can render its own
    @ViewBuilder
    func hidingNavigationBar() -> some View {
        let content = background(
            NavigationControllerReader { $0.allowSwipeBackWithoutBar() }
        )

        if #available(iOS 16.0, *) {
            content.toolbar(.hidden, for: .navigationBar)
        } else {
            content.navigationBarHidden(true)
        }
    }
}

// MARK: - NavigationControllerReader

private struct NavigationControllerReader: UIViewControllerRepresentable {
    let didFind: (UINavigationController) -> Void

    func makeUIViewController(context _: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context _: Context) {
        DispatchQueue.main.async { [weak uiViewController] in
            guard let navigationController = uiViewController?.navigationController else { return }

            didFind(navigationController)
        }
    }
}

// MARK: - Letting the pop gestures begin without a bar.

private extension UINavigationController {
    func allowSwipeBackWithoutBar() {
        interactivePopGestureRecognizer?.delegate = nil
        interactivePopGestureRecognizer?.isEnabled = true

        // iOS 26 also pops from anywhere in the content, and declines on the same grounds.
        if #available(iOS 26.0, *) {
            interactiveContentPopGestureRecognizer?.delegate = nil
            interactiveContentPopGestureRecognizer?.isEnabled = true
        }
    }
}
