//
//  UIViewController+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/22.
//

import UIKit
import Vision

extension UIViewController {

    enum TabBarIndex: Int {

        // swiftlint:disable identifier_name
        case journal = 0
        case card = 1
        case explore = 2
        case my = 3
    }

    static var identifier: String {

        return String(describing: self)
    }

    static func getLastPresentedViewController() -> UIViewController? {

        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

        let window = sceneDelegate?.window

        var presentedViewController = window?.rootViewController

        while presentedViewController?.presentedViewController != nil {

            presentedViewController = presentedViewController?.presentedViewController
        }

        return presentedViewController
    }

    func goToDesignatedTab(_ tabBarIndex: TabBarIndex) {

        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        let tabBar = sceneDelegate?.window?.rootViewController as? UITabBarController

        sceneDelegate?.window?.rootViewController?.dismiss(animated: true, completion: {
            tabBar?.selectedIndex = tabBarIndex.rawValue
        })
    }
}
