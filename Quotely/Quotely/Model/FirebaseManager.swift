//
//  FirebaseManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

typealias GenericCompletion<T: Decodable> = (([T]?, Error?) -> Void)
typealias StatusCompletion = ((Result<String, Error>) -> Void)

class FirebaseManager {

    enum FirebaseCollection: String {
        case journals, cards, posts, postComments, users

        var idField: String {
            switch self {
            case .journals: return "journalID"
            case .cards: return "cardID"
            case .posts: return "postID"
            case .postComments: return "postCommentID"
            case .users: return "uid"
            }
        }
    }

    enum FirebaseDataID: String {
        case journalID, cardID, postID, postCommentID, uid
    }

    enum FirebaseAction: Int64 {
        case positive = 1
        case negative = -1
    }

    enum FirebaseUpdateType: String {
        case like, comment
    }

    enum FirebaseField: String {
        case commentNumber
    }

    static let shared = FirebaseManager()

    private init() {}

    func updateFieldNumber(
        collection: FirebaseCollection,
        targetID: String,
        action: FirebaseAction,
        updateType: FirebaseUpdateType,
        completion: @escaping StatusCompletion
    ) {

        let targetCollection = Firestore.firestore().collection(collection.rawValue)

        targetCollection
            .whereField(collection.idField, isEqualTo: targetID)
            .getDocuments { querySnapshot, error in

                if let error = error {

                    completion(.failure(error))

                }

                let targetDocument = querySnapshot?.documents.first

                if updateType == .comment {

                    targetDocument?.reference.updateData([
                        "commentNumber": FieldValue.increment(action.rawValue)
                    ], completion: { error in

                        if let error = error {
                            completion(.failure(error))
                        }
                    })

                    completion(.success("Updated document successfully"))

                } else {

                    targetDocument?.reference.updateData([
                        "likeNumber": FieldValue.increment(action.rawValue)
                    ], completion: { error in

                        if let error = error {
                            completion(.failure(error))
                        }
                    })

                    switch action {

                    case .positive:

                        targetDocument?.reference.updateData([
                            "likeUser": FieldValue.arrayUnion([UserManager.shared.visitorUserInfo?.uid as Any])
                        ], completion: { error in

                            if let error = error {
                                completion(.failure(error))
                            }
                        })

                    case .negative:

                        targetDocument?.reference.updateData([
                            "likeUser": FieldValue.arrayRemove([UserManager.shared.visitorUserInfo?.uid as Any])
                        ], completion: { error in

                            if let error = error {
                                completion(.failure(error))
                            }
                        })
                    }

                    completion(.success("Updated document successfully"))
                }
            }
    }

    func deleteDocument(
        collection: FirebaseCollection,
        targetID: String,
        completion: @escaping StatusCompletion
    ) {

        let targetCollection = Firestore.firestore().collection(collection.rawValue)

        targetCollection
            .whereField(collection.idField, isEqualTo: targetID)
            .getDocuments { querySnapshot, error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    let targetDocument = querySnapshot?.documents.first

                    targetDocument?.reference.delete()

                    completion(.success("Delete data successfully"))
                }
            }
    }
}
