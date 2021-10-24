//
//  PostProvider.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import FirebaseFirestore

enum LikeAction: Int64 {

    case like = 1

    case dislike = -1
}

class PostManager {

    static let shared = PostManager()

    private init() {}

    let posts = Firestore.firestore().collection("posts")

    func publishPost(post: inout Post, completion: @escaping (Result<String, Error>) -> Void) {

        let document = posts.document()

        post.postID = document.documentID

        do {

            _ = try posts.addDocument(from: post, encoder: Firestore.Encoder(), completion: { error in

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

    func updatePost(
        postID: String,
        content: String,
        imageUrl: String?,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        posts.whereField("postID", isEqualTo: postID).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetPost = querySnapshot?.documents.first

                targetPost?.reference.updateData([
                    "content": content,
                    "imageUrl": imageUrl as Any
                ])

                completion(.success("Updated post content"))
            }
        }
    }

    func fetchPost(completion: @escaping (Result<[Post], Error>) -> Void) {

        posts.order(by: "createdTime", descending: true).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            } else {

                var posts = [Post]()

                for document in querySnapshot!.documents {

                    do {
                        if let post = try document.data(
                            as: Post.self, decoder: Firestore.Decoder()
                        ) {

                            posts.append(post)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(posts))
            }
        }
    }

    func updateLikes(postID: String, likeAction: LikeAction, completion: @escaping (Result<String, Error>) -> Void) {

        posts.whereField("postID", isEqualTo: postID).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetPost = querySnapshot?.documents.first

                switch likeAction {

                case .like:

                    targetPost?.reference.updateData(
                        ["likeNumber": FieldValue.increment(Int64(likeAction.rawValue)),
                         "likeUser": FieldValue.arrayUnion(["test123456"] as [Any])
                        ])

                case .dislike:

                    targetPost?.reference.updateData(
                        ["likeNumber": FieldValue.increment(Int64(likeAction.rawValue)),
                         "likeUser": FieldValue.arrayRemove(["test123456"] as [Any])
                        ])
                }

                completion(.success("changed like number"))
            }
        }
    }

    func deletePost(
        postID: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        posts.whereField("postID", isEqualTo: postID).getDocuments { querySnapshot, error in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetPost = querySnapshot?.documents.first

                targetPost?.reference.delete()

                completion(.success("Deleted post"))
            }
        }
    }

    func listenToPostUpdate(completion: @escaping (Result<[Post], Error>) -> Void) {

        posts.order(by: "createdTime", descending: true).addSnapshotListener { (documentSnapshot, error) in

            if let error = error {

                completion(.failure(error))

            } else {

                var posts = [Post]()

                for document in documentSnapshot!.documents {

                    do {

                        if let post = try document.data(as: Post.self, decoder: Firestore.Decoder()

                        ) {

                            posts.append(post)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }
                completion(.success(posts))
            }
        }
    }
}