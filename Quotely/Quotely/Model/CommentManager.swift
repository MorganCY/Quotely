//
//  DetailManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class CommentManager {

    static let shared = CommentManager()

    private init() {}

    let articleComments = Firestore.firestore().collection("articleComments")

    let postComments = Firestore.firestore().collection("postComments")

    func addComment(
        comment: inout Comment,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let document = postComments.document()
        comment.postCommentID = document.documentID

        document.setData(comment.toDict) { error in

            if let error = error {

                completion(.failure(error))

            } else {

                completion(.success("Success"))
            }
        }
    }

    func fetchComment(
        postID: String,
        completion: @escaping (Result<[Comment], Error>) -> Void
    ) {

        postComments
            .whereField("postID", isEqualTo: postID)
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
        postCommentID: String,
        newContent: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        postComments.whereField("postCommentID", isEqualTo: postCommentID).getDocuments { querySnapshot, error in

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
        postCommentID: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        postComments.whereField("postCommentID", isEqualTo: postCommentID).getDocuments { querySnapshot, error in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetComment = querySnapshot?.documents.first

                targetComment?.reference.delete()

                completion(.success("Deleted content"))
            }
        }
    }
}
