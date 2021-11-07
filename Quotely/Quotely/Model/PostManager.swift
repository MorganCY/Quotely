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

    enum FilterType: String {

        case latest = "最新"
        case popular = "熱門"
        case following = "追蹤"
        case user
    }

    static let shared = PostManager()

    let visitorUid = SignInManager.shared.uid

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
        editTime: Int64,
        content: String,
        imageUrl: String?,
        hashtag: String?,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        posts.whereField("postID", isEqualTo: postID).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetPost = querySnapshot?.documents.first

                targetPost?.reference.updateData([
                    "editTime": editTime,
                    "content": content,
                    "imageUrl": imageUrl as Any,
                    "hashtag": hashtag as Any
                ])

                completion(.success("Updated post content"))
            }
        }
    }

    func fetchPost(
        type: FilterType,
        uid: String?,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {

        switch type {

        case .latest:

            posts
                .order(by: "createdTime", descending: true)
                .getDocuments { (querySnapshot, error) in

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

        case .popular:

            posts
                .order(by: "likeNumber", descending: true)
                .order(by: "createdTime", descending: true)
                .getDocuments { (querySnapshot, error) in

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

        case .following: break

        case .user:

            guard let uid = uid else { return }

            posts
                .whereField("uid", isEqualTo: uid)
                .order(by: "createdTime", descending: true)
                .getDocuments { (querySnapshot, error) in

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
                         "likeUser": FieldValue.arrayUnion([self.visitorUid as Any])
                        ])

                case .dislike:

                    targetPost?.reference.updateData(
                        ["likeNumber": FieldValue.increment(Int64(likeAction.rawValue)),
                         "likeUser": FieldValue.arrayRemove([self.visitorUid as Any])
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

    func listenToPostUpdate(
        type: FilterType,
        uid: String?,
        followingList: [String]?,
        completion: @escaping (Result<[Post], Error>
        ) -> Void
    ) -> ListenerRegistration {

        switch type {

        case .latest:

            return posts
                .order(by: "createdTime", descending: true)
                .addSnapshotListener { (documentSnapshot, error) in

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

        case .popular:

            return posts
                .order(by: "likeNumber", descending: true)
                .order(by: "createdTime", descending: true)
                .addSnapshotListener { (documentSnapshot, error) in

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

        case.following:

            return posts
                .whereField("uid", in: followingList ?? [""])
                .order(by: "createdTime", descending: true)
                .addSnapshotListener { (documentSnapshot, error) in

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

        case .user:

            return posts
                .whereField("uid", isEqualTo: uid)
                .order(by: "createdTime", descending: true)
                .addSnapshotListener { (documentSnapshot, error) in

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
}
