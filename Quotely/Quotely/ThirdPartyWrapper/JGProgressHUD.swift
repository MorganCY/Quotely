//
//  JGProgressHUD.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation
import JGProgressHUD

class Toast {

    static let shared = Toast()

    private init() { }

    let hud = JGProgressHUD(style: .dark)

    var view = UIViewController.getLastPresentedViewController()?.view

    static func showSuccess(text: String) {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                showSuccess(text: text)
            }

            return
        }

        shared.hud.textLabel.text = text

        shared.hud.indicatorView = JGProgressHUDSuccessIndicatorView()

        shared.hud.show(in: shared.view ?? UIView())

        shared.hud.dismiss(afterDelay: 1.5)
    }

    static func showLoading(text: String) {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                showLoading(text: text)
            }

            return
        }

        shared.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()

        shared.hud.textLabel.text = text

        shared.hud.show(in: shared.view ?? UIView())
    }

    static func showFailure(text: String) {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                showFailure(text: text)
            }

            return
        }

        shared.hud.textLabel.text = text

        shared.hud.indicatorView = JGProgressHUDErrorIndicatorView()

        shared.hud.show(in: shared.view ?? UIView())

        shared.hud.dismiss(afterDelay: 1.5)
    }
}
