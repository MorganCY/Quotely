//
//  SettingsViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/6.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

    let options = ["封鎖名單", "隱私權政策", "登出", "刪除帳號"]

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setupTableView()
        }
    }
    let logoImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupImageView()
        view.backgroundColor = .BG
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logoImageView.fadeInAnimation(duration: 2.0)
    }

    func performSignOut() {

        SignInManager.shared.performSignOut { result in

            switch result {

            case .success(let success):
                print(success)

                guard let authVC =
                        UIStoryboard.auth.instantiateViewController(
                            withIdentifier: AuthViewController.identifier
                        ) as? AuthViewController
                else { return }

                let window = UIApplication.shared.windows.first

                window?.rootViewController = authVC

            case .failure(let error):
                print(error)
            }
        }
    }

    func tapBlockListButton() {

        guard let blockListVC =
                UIStoryboard.profile.instantiateViewController(
                    withIdentifier: BlockListViewController.identifier
                ) as? BlockListViewController
        else { return }

        let navigationVC = BaseNavigationController(rootViewController: blockListVC)

        self.present(navigationVC, animated: true)
    }

    func tapSignOutButton() {

        let alert = UIAlertController(title: "確定要登出嗎？", message: nil, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "確定登出", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.performSignOut()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        if let popoverController = alert.popoverPresentationController {

            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        alert.addAction(confirm)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }

    func tapDeleteAccountButton() {

        let alert = UIAlertController(title: "刪除帳號", message: "請聯繫 nihao0705@gmail.com", preferredStyle: .alert)

        if let popoverController = alert.popoverPresentationController {

            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    func tapPrivacyPolicyButton() {

        guard let policyVC =
                UIStoryboard.auth.instantiateViewController(
                    withIdentifier: PrivacyPolicyViewController.identifier
                ) as? PrivacyPolicyViewController
        else { return }

        let navigationVC = BaseNavigationController(rootViewController: policyVC)

        present(navigationVC, animated: true)
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
            case 1: self.tapPrivacyPolicyButton()
            case 2: self.tapSignOutButton()
            case 3: self.tapDeleteAccountButton()

            default: break
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension SettingsViewController {

    @objc func dismissSelf(_ sender: UIBarButtonItem) {

        dismiss(animated: true, completion: nil)
    }

    func setupNavigation() {

        navigationItem.title = "設定"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf(_:)))
    }

    func setupTableView() {

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.registerCellWithNib(identifier: SettingsTableViewCell.identifier, bundle: nil)
    }

    func setupImageView() {

        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage.asset(.logo)
        logoImageView.alpha = 0

        NSLayoutConstraint.activate([
            logoImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.height * 1 / 4)
        ])
    }
}
