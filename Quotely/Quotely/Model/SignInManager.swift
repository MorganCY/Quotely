//
//  SignInManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/3.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class SignInManager: NSObject {

    static let shared = SignInManager()

    let uid = Auth.auth().currentUser?.uid

    private override init() { super.init() }

    fileprivate var currentNonce: String?

    fileprivate var userName = ""

    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

    func performSignIn() {

        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self

        authorizationController.performRequests()
    }

    func performSignOut() {

        do {

            try Auth.auth().signOut()

        } catch {

            print("Cannot sign out")
        }
    }

    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce

        return request
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {

      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension SignInManager: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login call back was received, but no login request was sent")
            }

            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }

            if let givenName = appleIDCredential.fullName?.givenName,
               let familyName = appleIDCredential.fullName?.familyName {

                self.userName = "\(givenName) \(familyName)"

            } else {

                self.userName = "尚未取名的用戶"
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                fatalError("Unable to print serialize token string from data: \(appleIDToken.debugDescription)")
            }

            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )

            Auth.auth().signIn(with: credential) { (authResult, error) in

                if let user = authResult?.user {
                    print("User has already signed in as \(user.uid), \(String(describing: user.email))")

                    if authResult?.additionalUserInfo?.isNewUser == true {

                        let user = User(
                            uid: user.uid,
                            name: self.userName,
                            saying: nil,
                            registerTime: user.metadata.creationDate?.millisecondsSince1970,
                            provider: "Apple",
                            postID: nil,
                            likeCardID: nil,
                            dislikeCardID: nil,
                            journalID: nil,
                            following: nil,
                            follower: nil,
                            blocklist: nil,
                            followingNumber: 0,
                            followerNumber: 0,
                            postNumber: 0
                        )

                        UserManager.shared.createUser(user: user) { result in

                            switch result {

                            case .success(let success):
                                print(success)

                            case .failure(let error):
                                print(error)
                            }
                        }
                    }

                    guard let window = self.sceneDelegate?.window else {
                        fatalError("Cannot get window")
                    }

                    guard let tabBarVC = UIStoryboard
                            .main
                            .instantiateViewController(
                                withIdentifier: String(describing: TabBarViewController.self)
                    ) as? TabBarViewController else {

                        return
                    }

                    window.rootViewController = tabBarVC
                }

                if error != nil {

                    print(error?.localizedDescription)
                    return
                }

            }
        }
    }
}

extension SignInManager: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

        guard let window = sceneDelegate?.window else {
            fatalError("Cannot get window")
        }

        return window
    }
}
