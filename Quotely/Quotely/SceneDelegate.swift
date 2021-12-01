//
//  SceneDelegate.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var userListener: ListenerRegistration?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }

        if let visitorUid = Auth.auth().currentUser?.uid {

            userListener = UserManager.shared.listenToUserUpdate(
                uid: visitorUid
            ) { result in

                switch result {

                case .success(let user):

                    print(user)

                    UserManager.shared.visitorUserInfo = user

                    SignInManager.shared.visitorUid = user.uid

                case .failure(let error):

                    print(error)
                }
            }

        } else {

            if let windowScene = scene as? UIWindowScene {

                let window = UIWindow(windowScene: windowScene)

                guard let authVC =
                        UIStoryboard.auth.instantiateViewController(
                            withIdentifier: AuthViewController.identifier
                        ) as? AuthViewController
                else { return }

                window.rootViewController = authVC

                self.window = window
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

        if Auth.auth().currentUser?.uid != nil {

            userListener = UserManager.shared.listenToUserUpdate(
                uid: SignInManager.shared.visitorUid ?? ""
            ) { result in

                switch result {

                case .success(let user):

                    print(user)

                    UserManager.shared.visitorUserInfo = user

                    SignInManager.shared.visitorUid = user.uid

                case .failure(let error):

                    print(error)
                }
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {

        userListener?.remove()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

