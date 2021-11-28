//
//  JGProgressHUD.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation
import JGProgressHUD

enum ToastText: String {

    case scanning = "掃描中"
    case uploading = "上傳中"

    case remindInput = "請輸入內容"
    case remindImage = "沒有選取圖片"

    case successUpdated = "更新成功"
    case failToUpdate = "更新失敗"

    case failToScan = "掃描失敗"
    case failToAddPost = "新增想法失敗"
    case failToUpload = "上傳失敗"
}

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

        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

        shared.hud.show(in: sceneDelegate?.window ?? UIView())

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

        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

        shared.hud.show(in: sceneDelegate?.window ?? UIView())
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

        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

        shared.hud.show(in: sceneDelegate?.window ?? UIView())

        shared.hud.dismiss(afterDelay: 1.5)
    }
}
