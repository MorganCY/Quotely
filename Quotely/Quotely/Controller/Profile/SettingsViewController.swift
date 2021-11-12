//
//  SettingsViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/6.
//

import Foundation
import UIKit
import SwiftUI

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.backgroundColor = .M3
            tableView.separatorStyle = .none
            tableView.registerCellWithNib(identifier: SettingsTableViewCell.identifier, bundle: nil)
        }
    }

    let options = ["封鎖名單", "登出", "刪除帳號"]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "設定"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf(_:))
        )
    }

    func performSignOut() {

        SignInManager.shared.performSignOut { result in

            switch result {

            case .success(let success):
                print(success)

                guard let authVC =
                        UIStoryboard.auth
                        .instantiateViewController(
                            withIdentifier: String(describing: AuthViewController.self)
                        ) as? AuthViewController else {

                            return
                        }

                let window = UIApplication.shared.windows.first

                window?.rootViewController = authVC

            case .failure(let error):
                print(error)
            }
        }
    }

    func tapBlockListButton() {

        guard let blockListVC =
                UIStoryboard.profile
                .instantiateViewController(
                    withIdentifier: String(describing: BlockListViewController.self)
                ) as? BlockListViewController else {

                    return
                }

        let navigationVC = BaseNavigationController(rootViewController: blockListVC)

        self.present(navigationVC, animated: true)
    }

    func tapSignOutButton() {

        let alert = UIAlertController(title: "確定要登出嗎？", message: nil, preferredStyle: .alert)

        let confirm = UIAlertAction(title: "確定登出", style: .destructive) { _ in

            self.performSignOut()
        }

        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(confirm)

        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }

    func tapDeleteAccountButton() {

        let alert = UIAlertController(title: "刪除帳號", message: "請聯繫 nihao0705@gmail.com", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    @objc func dismissSelf(_ sender: UIBarButtonItem) {

        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { options.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath
        ) as? SettingsTableViewCell else {

            fatalError("Cannot create cell")
        }

        cell.layoutCell(buttonTitle: options[indexPath.row])

        cell.hideSelectionStyle()

        cell.buttonHandler = {

            switch indexPath.row {

            case 0: self.tapBlockListButton()

            case 1: self.tapSignOutButton()

            case 2: self.tapDeleteAccountButton()

            default: break
            }
        }

        return cell
    }
}
