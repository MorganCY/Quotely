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
import UIKit

class UserManager {

    enum FollowAction: Int {

        case follow = 1
        case unfollow = -1
    }

    enum PostAction: Int {

        case publish = 1
        case delete = -1
    }

    enum BlockAction: Int {

        case block = 1
        case unblock = -1
    }

    static let shared = UserManager()

    private init() {}

    var visitorUserInfo: User?

    let users = Firestore.firestore().collection("users")

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

                            "likeCardList": FieldValue.arrayUnion([cardID])
                        ])

                        completion(.success("Favorite card list was updated"))

                    case .dislike:

                        document.reference.updateData([

                            "likeCardList": FieldValue.arrayRemove([cardID])
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

    func updateUserPost(
        uid: String,
        postID: String,
        postAction: PostAction,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let reference = users.document(uid)

        reference.getDocument { document, error in

            if let document = document, document.exists {

                switch postAction {

                case .publish:

                    document.reference.updateData([

                        "postNumber": FieldValue.increment(Int64(postAction.rawValue)),

                        "postList": FieldValue.arrayUnion([postID])
                    ])

                case .delete:

                    document.reference.updateData([

                        "postNumber": FieldValue.increment(Int64(postAction.rawValue)),

                        "postList": FieldValue.arrayRemove([postID])
                    ])

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
        uid: String,
        profileImageUrl: String?,
        userName: String?,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let reference = users.document(uid)

        reference.getDocument { document, error in

            if let document = document, document.exists {

                if let profileImageUrl = profileImageUrl {

                    document.reference.updateData([

                        "profileImageUrl": profileImageUrl
                    ])
                }

                if let userName = userName {

                    document.reference.updateData([

                        "name": userName
                    ])
                }

                completion(.success("User information was updated"))

            } else {

                if let error = error {

                    completion(.failure(error))
                }
            }
        }
    }

    func updateUserFollow(
        visitorUid: String,
        visitedUid: String,
        followAction: FollowAction,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let visitorReference = users.document(visitorUid)

        let visitedReference = users.document(visitedUid)

        visitorReference.getDocument { document, error in

            if let document = document, document.exists {

                switch followAction {
                case .follow:

                    document.reference.updateData([

                        "followingNumber": FieldValue.increment(Int64(followAction.rawValue)),

                        "following": FieldValue.arrayUnion([visitedUid])
                    ])

                case .unfollow:

                    document.reference.updateData([

                        "followingNumber": FieldValue.increment(Int64(followAction.rawValue)),

                        "following": FieldValue.arrayRemove([visitedUid])
                    ])
                }

                completion(.success("Visitor follow was updated"))

            } else {

                if let error = error {

                    completion(.failure(error))
                }
            }
        }

        visitedReference.getDocument { document, error in

            if let document = document, document.exists {

                switch followAction {
                case .follow:

                    document.reference.updateData([

                        "followerNumber": FieldValue.increment(Int64(followAction.rawValue)),

                        "follower": FieldValue.arrayUnion([visitorUid])
                    ])

                case .unfollow:

                    document.reference.updateData([

                        "followerNumber": FieldValue.increment(Int64(followAction.rawValue)),

                        "follower": FieldValue.arrayRemove([visitorUid])
                    ])
                }

                completion(.success("Visitor follow was updated"))

            } else {

                if let error = error {

                    completion(.failure(error))
                }
            }
        }
    }

    func listenToUserUpdate(
        uid: String,
        completion: @escaping (Result<User, Error>
        ) -> Void) {

        users.document(uid).addSnapshotListener { documentSnapshot, error in

            if let error = error {

                completion(.failure(error))

            } else {

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
    }

    func updateUserBlockList(
        visitorUid: String,
        visitedUid: String,
        blockAction: BlockAction,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let reference = users.document(visitorUid)

        reference.getDocument { document, error in

            if let document = document, document.exists {

                switch blockAction {
                case .block:

                    document.reference.updateData([

                        "blockList": FieldValue.arrayUnion([visitedUid]),
                        "blockNumber": FieldValue.increment(Int64(blockAction.rawValue))
                    ])

                case .unblock:

                    document.reference.updateData([

                        "blockList": FieldValue.arrayRemove([visitedUid]),
                        "blockNumber": FieldValue.increment(Int64(blockAction.rawValue))
                    ])

                }

                completion(.success("User information was updated"))

            } else {

                if let error = error {

                    completion(.failure(error))
                }
            }
        }
    }
}
