//
//  FirebaseManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/23.
//

import Foundation
import FirebaseFirestore

typealias StatusCompletion = ((Result<String, Error>) -> Void)

enum FirebaseAction: Int64 {
    case positive = 1
    case negative = -1
}

final class FirebaseManager {

    private init() {}

    enum FirebaseCollection: String {
        case journals, cards, posts, postComments

        var idField: String {
            switch self {
            case .journals: return "journalID"
            case .cards: return "cardID"
            case .posts: return "postID"
            case .postComments: return "postCommentID"
            }
        }
    }

    enum FirebaseDataID: String {
        case journalID, cardID, postID, postCommentID
    }

    enum FirebaseUpdateType: String {
        case like, comment

        var numberField: String {
            switch self {
            case .like: return "likeNumber"
            case .comment: return "commentNumber"
            }
        }

        var arrayField: String {
            switch self {
            case .like: return "likeUser"
            case .comment: return ""
            }
        }
    }

    enum FirebaseField: String {
        case commentNumber
    }

    static let shared = FirebaseManager()

    func updateFieldNumber(
        collection: FirebaseCollection,
        targetID: String,
        action: FirebaseAction,
        updateType: FirebaseUpdateType,
        completion: @escaping StatusCompletion
    ) {

        let targetCollection = Firestore.firestore().collection(collection.rawValue)
            .whereField(collection.idField, isEqualTo: targetID)

        var numberField: String {
            updateType.numberField
        }

        var arrayField: String {
            switch updateType {
            case .like: return "likeUser"
            case .comment: return ""
            }
        }

        targetCollection.getDocuments { querySnapshot, error in

            if let error = error {
                completion(.failure(error))
            }

            let targetDocument = querySnapshot?.documents.first

            if updateType == .comment {

                targetDocument?.reference.updateData([
                    numberField: FieldValue.increment(action.rawValue)
                ], completion: { error in
                    if let error = error {
                        completion(.failure(error))
                    }
                })
                completion(.success("Updated document successfully"))

            } else {

                targetDocument?.reference.updateData([
                    numberField: FieldValue.increment(action.rawValue)
                ], completion: { error in
                    if let error = error {
                        completion(.failure(error))
                    }
                })

                switch action {

                case .positive:

                    targetDocument?.reference.updateData([
                        arrayField: FieldValue.arrayUnion([UserManager.shared.visitorUserInfo?.uid as Any])
                    ], completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    })

                case .negative:

                    targetDocument?.reference.updateData([
                        arrayField: FieldValue.arrayRemove([UserManager.shared.visitorUserInfo?.uid as Any])
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

        let targetCollection = Firestore.firestore()
            .collection(collection.rawValue)
            .whereField(collection.idField, isEqualTo: targetID)

        targetCollection.getDocuments { querySnapshot, error in

            if let error = error {
                completion(.failure(error))
            }

            let targetDocument = querySnapshot?.documents.first

            targetDocument?.reference.delete(completion: { error in
                if let error = error {
                    completion(.failure(error))
                }
            })
            completion(.success("Delete data successfully"))
        }
    }
}
