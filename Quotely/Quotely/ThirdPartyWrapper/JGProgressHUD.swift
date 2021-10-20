//
//  JGProgressHUD.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation
import JGProgressHUD

class ProgressHUD {

    static let shared = ProgressHUD()

    private init() { }

    let hud = JGProgressHUD(style: .dark)

//    var view: UIView {
//
//        return AppDelegate.shared.window!.rootViewController!.view
//    }

    static func showSuccess(text: String) {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                showSuccess(text: text)
            }

            return
        }

        shared.hud.textLabel.text = text

        shared.hud.indicatorView = JGProgressHUDSuccessIndicatorView()

//        shared.hud.show(in: shared.view)

        shared.hud.dismiss(afterDelay: 1.5)
    }
}
