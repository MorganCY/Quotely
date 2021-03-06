//
//  UserManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/28.
//

import Foundation
import Firebase

final class UserManager {

    private init() {}

    enum UserAction {
        case follow, block
    }

    static let shared = UserManager()

    var visitorUserInfo: User?

    let users = Firestore.firestore().collection("users")

    func createUser(
        user: User,
        completion: @escaping StatusCompletion
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

    func fetchUserInfo(
        uid: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {

        let reference = users.document(uid)

        reference.getDocument { document, error in

            if let document = document,
                document.exists {

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

    func listenToUserUpdate(
        uid: String,
        completion: @escaping (Result<User, Error>
        ) -> Void
    ) -> ListenerRegistration {

        return users.document(uid).addSnapshotListener { documentSnapshot, error in

            if let error = error {
                completion(.failure(error))
            }

            do {
                if let userInfo = try documentSnapshot?.data(
                    as: User.self
                ) {
                    completion(.success(userInfo))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    func updateFavoriteCard(
        cardID: String,
        likeAction: FirebaseAction,
        completion: @escaping StatusCompletion
    ) {

        let reference = users.document(UserManager.shared.visitorUserInfo?.uid ?? "")

        reference.getDocument { document, error in

            if let document = document, document.exists {

                switch likeAction {

                case .positive:

                    document.reference.updateData([
                        "likeCardList": FieldValue.arrayUnion([cardID])
                    ], completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    })

                    completion(.success("Favorite card list was updated"))

                case .negative:

                    document.reference.updateData([
                        "likeCardList": FieldValue.arrayRemove([cardID])
                    ], completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    })
                    completion(.success("Favorite card list was updated"))
                }
            } else {
                if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }

    func updateUserPost(
        postID: String,
        postAction: FirebaseAction,
        completion: @escaping StatusCompletion
    ) {

        let reference = users.document(UserManager.shared.visitorUserInfo?.uid ?? "")

        reference.getDocument { document, error in

            if let document = document,
               document.exists {

                switch postAction {

                case .positive:

                    document.reference.updateData([
                        "postNumber": FieldValue.increment(Int64(postAction.rawValue)),
                        "postList": FieldValue.arrayUnion([postID])
                    ], completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    })

                case .negative:

                    document.reference.updateData([
                        "postNumber": FieldValue.increment(Int64(postAction.rawValue)),
                        "postList": FieldValue.arrayRemove([postID])
                    ], completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    })
                }

                completion(.success("Updated user post number and post list"))

            } else {

                if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }

    func updateUserInfo(
        profileImageUrl: String?,
        userName: String?,
        completion: @escaping StatusCompletion
    ) {

        let reference = users.document(UserManager.shared.visitorUserInfo?.uid ?? "")

        reference.getDocument { document, error in

            if let document = document, document.exists {

                if let profileImageUrl = profileImageUrl {

                    document.reference.updateData([
                        "profileImageUrl": profileImageUrl
                    ], completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    })
                }

                if let userName = userName {

                    document.reference.updateData([
                        "name": userName
                    ], completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    })
                }
                completion(.success("User information was updated"))

            } else {

                if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }

    func updateUserList(
        userAction: UserAction,
        visitedUid: String,
        action: FirebaseAction,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let visitorReference = users.document(UserManager.shared.visitorUserInfo?.uid ?? "")

        let visitedReference = users.document(visitedUid)

        var numberField: String {
            switch userAction {
            case .follow: return "followingNumber"
            case .block: return "blockNumber"
            }
        }

        var listField: String {
            switch userAction {
            case .follow: return "followingList"
            case .block: return "blockList"
            }
        }

        visitorReference.getDocument { document, error in

            if let error = error {

                completion(.failure(error))
            }

            if let document = document, document.exists {

                switch action {

                case .positive:

                    document.reference.updateData([
                        numberField: FieldValue.increment(Int64(action.rawValue)),
                        listField: FieldValue.arrayUnion([visitedUid])
                    ], completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    })

                case .negative:

                    document.reference.updateData([
                        numberField: FieldValue.increment(Int64(action.rawValue)),
                        listField: FieldValue.arrayRemove([visitedUid])
                    ], completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    })
                }
                completion(.success("Visitor follow/block was updated"))
            }
        }

        if userAction == .follow {

            visitedReference.getDocument { document, error in

                if let document = document, document.exists {

                    if let error = error {
                        completion(.failure(error))
                    }

                    switch action {

                    case .positive:

                        document.reference.updateData([
                            "followerNumber": FieldValue.increment(Int64(action.rawValue)),
                            "followerList": FieldValue.arrayUnion([UserManager.shared.visitorUserInfo?.uid ?? ""])
                        ], completion: { error in
                            if let error = error {
                                completion(.failure(error))
                            }
                        })

                    case .negative:

                        document.reference.updateData([
                            "followerNumber": FieldValue.increment(Int64(action.rawValue)),
                            "followerList": FieldValue.arrayRemove([UserManager.shared.visitorUserInfo?.uid ?? ""])
                        ], completion: { error in
                            if let error = error {
                                completion(.failure(error))
                            }
                        })
                    }
                    completion(.success("Visitor follow/block was updated"))
                }
            }
        }
    }
}
