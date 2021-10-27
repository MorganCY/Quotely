//
//  UIViewController+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/22.
//

import UIKit
extension UIViewController {

static func getLastPresentedViewController() -> UIViewController? {

        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

        let window = sceneDelegate?.window

        var presentedViewController = window?.rootViewController

        while presentedViewController?.presentedViewController != nil {

            presentedViewController = presentedViewController?.presentedViewController
        }

        return presentedViewController
    }
}
