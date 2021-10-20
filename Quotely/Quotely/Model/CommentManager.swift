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

    func addComment(comment: Comment, completion: @escaping (Result<String, Error>) -> Void) {

        let document = postComments.document()

        document.setData(comment.toDict) { error in

            if let error = error {

                completion(.failure(error))

            } else {

                completion(.success("Success"))
            }
        }
    }

    func fetchComment(postID: String, completion: @escaping (Result<[Comment], Error>) -> Void) {

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
}
