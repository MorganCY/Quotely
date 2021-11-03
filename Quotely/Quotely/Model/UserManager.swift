//
//  UserManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/28.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import CoreMedia

class UserManager {

    static let shared = UserManager()

    private init() {}

    let users = Firestore.firestore().collection("users")

    func fetchUserInfo(
        uid: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {

        let reference = users.document(uid)

        reference.getDocument { document, error in

            if let document = document, document.exists {

                do {

                    if let userInfo = try document.data(
                        as: User.self
                    ) {

                        completion(.success(userInfo))
                    }

                } catch {

                    completion(.failure(error))
                }
            }
        }
    }

    func updateFavoriteCard(
        uid: String,
        cardID: String,
        likeAction: LikeAction,
        completion: @escaping (Result<String, Error>) -> Void) {

            let reference = users.document(uid)

            reference.getDocument { document, error in

                if let document = document, document.exists {

                    switch likeAction {

                    case .like:

                        document.reference.updateData([

                            "likeCardID": FieldValue.arrayUnion([cardID])
                        ])

                        completion(.success("Favorite card list was updated"))

                    case .dislike:

                        document.reference.updateData([

                            "likeCardID": FieldValue.arrayRemove([cardID])
                        ])

                        completion(.success("Favorite card list was updated"))
                    }

                } else {

                    if let error = error {

                        completion(.failure(error))
                    }
                }
            }
    }

    func createUser(
        user: User,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        do {

            _ = try users
                .document(user.uid)
                .setData(
                from: user,
                encoder: Firestore.Encoder(),
                completion: { error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    completion(.success("Created user"))
                }
            })

        } catch {

            completion(.failure(error))
        }
    }
}
