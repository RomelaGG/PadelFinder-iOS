//
//  TopViewController.swift
//  CoreSocialAuth
//
//  Created by Giorgi Romelashvili on 21.10.26.
//

import UIKit

/// Finds something for Google's SDK to present from.
///
/// `keyWindow.rootViewController` is the wrong answer here and worth being
/// explicit about: every entry into auth is already a modal - a
/// `fullScreenCover` from Welcome and Sign in, a `sheet` from the gate - so
/// presenting on the root controller either fails outright or puts Google's
/// sheet behind what the user is looking at. The top-most presented
/// controller is the only correct target.
enum TopViewController {

    @MainActor
    static func find() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first

        guard
            let window = scene?.windows.first(where: \.isKeyWindow) ?? scene?.windows.first,
            var controller = window.rootViewController
        else {
            return nil
        }

        while let presented = controller.presentedViewController {
            controller = presented
        }

        return controller
    }
}
