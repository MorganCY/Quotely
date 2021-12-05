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
        authViews.forEach { $0.fadeInAnimation(duration: 2.0) }
    }

    // swiftlint:disable function_body_length
    func configureAuthVC() {
        let claimerLabel = UILabel()
        let privacyPolicyButton = UIButton()
        let andLabel = UILabel()
        let eulaButton = UIButton()
        let claimerViews = [claimerLabel, privacyPolicyButton, andLabel, eulaButton]
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

        let labels = [claimerLabel, andLabel]
        let buttons = [privacyPolicyButton, eulaButton]

        labels.forEach {
            $0.textColor = .gray
            $0.font = UIFont.setRegular(size: 12)
        }

        buttons.forEach {
            $0.setTitleColor(.M1, for: .normal)
            $0.titleLabel?.font = UIFont.setBold(size: 12)
        }

        claimerLabel.text = "點擊下方按鈕登入代表您同意"
        andLabel.text = "與"
        privacyPolicyButton.setTitle("隱私權政策", for: .normal)
        eulaButton.setTitle("Apple標準許可協議", for: .normal)
        privacyPolicyButton.addTarget(self, action: #selector(tapPrivacyPolicyButton(_:)), for: .touchUpInside)
        eulaButton.addTarget(self, action: #selector(tapEulaButton(_:)), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(tapSignInWithAppleButton(_:)), for: .touchUpInside)

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

    @objc func tapSignInWithAppleButton(_ sender: ASAuthorizationAppleIDButton) {
        SignInManager.shared.performSignIn()
    }

    @objc func tapPrivacyPolicyButton(_ sender: UIButton) {
        guard let policyVC =
                UIStoryboard.auth.instantiateViewController(
                    withIdentifier: PrivacyPolicyViewController.identifier
                ) as? PrivacyPolicyViewController
        else { return }

        let navigationVC = BaseNavigationController(rootViewController: policyVC)

        present(navigationVC, animated: true)
    }

    @objc func tapEulaButton(_ sender: UIButton) {

        guard let eulaVC =
                UIStoryboard.auth.instantiateViewController(
                    withIdentifier: EULAViewController.identifier
                ) as? EULAViewController
        else { return }

        let navigationVC = BaseNavigationController(rootViewController: eulaVC)

        present(navigationVC, animated: true)
    }
}
