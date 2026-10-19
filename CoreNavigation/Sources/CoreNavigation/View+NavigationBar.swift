//
//  View+NavigationBar.swift
//  PresentationCashback
//
//  Created by Giorgi Romelashvili on 26.08.26.
//

import UIKit
import SwiftUI

// MARK: - restoringSwipeBack

extension View {
    /// Keeps the edge swipe alive on screens that take the back item away from
    /// UIKit with `navigationBarBackButtonHidden(true)`. UIKit disables the
    /// gesture along with the item, so it has to be switched back on by hand.
    ///
    /// Not for screens that hide the bar in order to suppress back: there the
    /// dead gesture is the point.
    func restoringSwipeBack() -> some View {
        background(
            NavigationControllerReader { $0.allowSwipeBackWithoutBar() }
        )
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

// MARK: - Letting the pop gestures begin without a back item.

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
