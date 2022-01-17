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

    case successAdd = "新增成功"
    case successUpdated = "更新成功"
    case successLike = "已收藏"
    case successSave = "已下載"

    case failToScan = "掃描失敗"
    case failToAdd = "新增失敗"
    case failToUpdate = "更新失敗"
    case failToDelete = "刪除失敗"
    case failToLike = "收藏失敗"
    case failToUpload = "上傳失敗"
    case failToSignOut = "登出失敗"
    case failToBlock = "封鎖失敗"
    case failToDownload = "資料載入異常"

    case noCamera = "沒有相機可使用"
    case noInstagram = "無法開啟Instagram"
}

final class Toast {

    static let shared = Toast()

    private init() { }

    let hud = JGProgressHUD(style: .dark)

    var view = UIViewController.getLastPresentedViewController()?.view

    func showSuccess(text: ToastText) {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                self.showSuccess(text: text)
            }

            return
        }

        hud.textLabel.text = text.rawValue

        hud.indicatorView = JGProgressHUDSuccessIndicatorView()

        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

        hud.show(in: sceneDelegate?.window ?? UIView())

        hud.dismiss(afterDelay: 1.5)
    }

    func showLoading(text: ToastText) {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                self.showLoading(text: text)
            }

            return
        }

        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()

        hud.textLabel.text = text.rawValue

        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

        hud.show(in: sceneDelegate?.window ?? UIView())
    }

    func showFailure(text: ToastText) {

        if !Thread.isMainThread {

            DispatchQueue.main.async {
                self.showFailure(text: text)
            }

            return
        }

        hud.textLabel.text = text.rawValue

        hud.indicatorView = JGProgressHUDErrorIndicatorView()

        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

        hud.show(in: sceneDelegate?.window ?? UIView())

        hud.dismiss(afterDelay: 1.5)
    }
}
