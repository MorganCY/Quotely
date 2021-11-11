//
//  AuthViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/3.
//

import Foundation
import UIKit
import AuthenticationServices

class AuthViewController: UIViewController {

    let logoImageView = UIImageView()
    let claimerLabel = UILabel()
    let privacyPolicyButton = UIButton()
    let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    let claimerStackView = UIStackView()
    var authViews: [UIView] {
        return [logoImageView, signInButton, claimerStackView]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .BG
        configureAuthVC()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        authViews.forEach { $0.fadeIn() }
    }

    func configureAuthVC() {
        let claimerViews = [claimerLabel, privacyPolicyButton]
        view.addSubview(claimerStackView)
        claimerStackView.translatesAutoresizingMaskIntoConstraints = false
        claimerViews.forEach {
            claimerStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        claimerStackView.axis = .horizontal
        claimerStackView.spacing = 2
        claimerStackView.distribution = .fill

        authViews.forEach {
            $0.alpha = 0
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        logoImageView.image = UIImage.asset(.logoWithText)
        claimerLabel.text = "點擊下方按鈕登入代表您同意"
        privacyPolicyButton.setTitle("隱私權政策", for: .normal)
        claimerLabel.textColor = .gray
        privacyPolicyButton.setTitleColor(.blue, for: .normal)
        claimerLabel.font = UIFont(name: "Pingfang TC", size: 12)
        privacyPolicyButton.titleLabel?.font = UIFont(name: "Pingfang TC", size: 12)
        signInButton.addTarget(self, action: #selector(handleSignInWithAppleTapped(_:)), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(handlePrivacyPolicyTapped(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([

            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            logoImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.height * 0.2),

            privacyPolicyButton.leadingAnchor.constraint(equalTo: claimerLabel.trailingAnchor, constant: 2),
            privacyPolicyButton.heightAnchor.constraint(equalTo: claimerLabel.heightAnchor),

            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(UIScreen.height * 0.22)),
            signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            signInButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            claimerStackView.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -16),
            claimerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func handleSignInWithAppleTapped(_ sender: ASAuthorizationAppleIDButton) {
        SignInManager.shared.performSignIn()
    }

    @objc func handlePrivacyPolicyTapped(_ sender: UIButton) {
        guard let policyVC =
                UIStoryboard.auth
                .instantiateViewController(
                    withIdentifier: String(describing: PrivacyPolicyViewController.self)
                ) as? PrivacyPolicyViewController else {

                    return
                }

        let navigationVC = BaseNavigationController(rootViewController: policyVC)

        present(navigationVC, animated: true)
    }
}
