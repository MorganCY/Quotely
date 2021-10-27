//
//  CardCommentManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum CommentAction: Int64 {

    case add = 1

    case delete = -1
}

class CardCommentManager {

    static let shared = CardCommentManager()

    private init() {}

    let cards = Firestore.firestore().collection("cards")

    let cardComments =
    Firestore.firestore().collection("cardComments")

    func addComment(
        comment: inout Comment,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let document = cardComments.document()

        comment.cardCommentID = document.documentID

        do {

            _ = try cardComments.addDocument(from: comment, encoder: Firestore.Encoder(), completion: { error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    completion(.success("Success"))
                }
            })

        } catch {

            completion(.failure(error))
        }
    }

    func updateCommentNumber(
        cardID: String,
        commentAction: CommentAction,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        cards.whereField("cardID", isEqualTo: cardID).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetCard = querySnapshot?.documents.first

                switch commentAction {

                case .add:

                    targetCard?.reference.updateData(
                        ["commentNumber": FieldValue.increment(Int64(commentAction.rawValue))
                        ])

                case .delete:

                    targetCard?.reference.updateData(
                        ["commentNumber": FieldValue.increment(Int64(commentAction.rawValue))
                        ])
                }

                completion(.success("changed comment number"))
            }
        }
    }

    func fetchComment(
        cardID: String,
        completion: @escaping (Result<[Comment], Error>) -> Void
    ) {

        cardComments
            .whereField("cardID", isEqualTo: cardID)
            .order(by: "createdTime", descending: true)
            .getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            } else {

                var comments = [Comment]()

                for document in querySnapshot!.documents {

                    do {

                        if let comment = try document.data(as: Comment.self, decoder: Firestore.Decoder()

                        ) {

                            comments.append(comment)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(comments))
            }
        }
    }

    func updateComment(
        cardCommentID: String,
        newContent: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        cardComments.whereField("cardCommentID", isEqualTo: cardCommentID).getDocuments { querySnapshot, error in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetComment = querySnapshot?.documents.first

                targetComment?.reference.updateData([
                    "content": newContent,
                    "editTime": Date().millisecondsSince1970
                ])

                completion(.success("Changed content"))
            }
        }
    }

    func deleteComment(
        cardCommentID: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        cardComments.whereField("cardCommentID", isEqualTo: cardCommentID).getDocuments { querySnapshot, error in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetComment = querySnapshot?.documents.first

                targetComment?.reference.delete()

                completion(.success("Deleted comment"))
            }
        }
    }
}
