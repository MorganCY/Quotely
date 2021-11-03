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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSignInWithAppleButton()
    }

    func setupSignInWithAppleButton() {

        let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        let signOutButton = UIButton()

        view.addSubview(signInButton)
        view.addSubview(signOutButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.translatesAutoresizingMaskIntoConstraints = false

        signInButton.addTarget(self, action: #selector(handleSignInWithAppleTapped(_:)), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(handleSignOutTapped(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([

            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: UIScreen.height * 0.2),
            signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            signInButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),

            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 16),
            signOutButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            signOutButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05)
        ])

        signOutButton.setTitle("登出", for: .normal)
        signOutButton.setTitleColor(.black, for: .normal)
    }

    @objc func handleSignInWithAppleTapped(_ sender: ASAuthorizationAppleIDButton) {

        SignInManager.shared.performSignIn()
    }

    @objc func handleSignOutTapped(_ sender: UIButton) {

        SignInManager.shared.performSignOut()
    }

}
