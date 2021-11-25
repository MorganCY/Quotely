//
//  PostProvider.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import FirebaseFirestore

class PostManager {

    private init() {}

    enum PilterType: String {

        case latest = "最新"
        case following = "追蹤"
        case user
    }

    static let shared = PostManager()

    let posts = Firestore.firestore().collection("posts")

    func createPost(
        post: inout Post,
        completion: @escaping StatusCompletion
    ) {

        let document = posts.document()

        post.postID = document.documentID

        do {

            _ = try posts.addDocument(from: post, encoder: Firestore.Encoder(), completion: { error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    completion(.success(document.documentID))
                }
            })

        } catch {

            completion(.failure(error))
        }
    }

    func fetchCardPost(
        cardID: String,
        completion: @escaping (Result<[Post]?, Error>) -> Void
    ) {

        posts
            .whereField("cardID", isEqualTo: cardID)
            .order(by: "createdTime", descending: true)
            .getDocuments { (querySnapshot, error) in

                if let error = error {

                    completion(.failure(error))
                }

                var posts = [Post]()

                for document in querySnapshot!.documents {

                    do {
                        if let post = try document.data(
                            as: Post.self, decoder: Firestore.Decoder()
                        ) {

                            if let blockList = UserManager.shared.visitorUserInfo?.blockList {

                                if !blockList.contains(post.uid) {

                                    posts.append(post)

                                }

                            } else {

                                posts.append(post)
                            }
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(posts))
            }
    }

    func listenToPostUpdate(
        type: PilterType,
        uid: String?,
        followingList: [String]?,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) -> ListenerRegistration {

        var query: Query {
            switch type {
            case .latest:
                return posts.order(by: "createdTime", descending: true)
            case .following:
                return posts.whereField("uid", in: followingList ?? [""]).order(by: "createdTime", descending: true)
            case .user:
                return posts.whereField("uid", isEqualTo: uid ?? "").order(by: "createdTime", descending: true)
            }
        }

        switch type {

        case .latest:

            return query.addSnapshotListener { (documentSnapshot, error) in

                if let error = error {

                    completion(.failure(error))

                }

                var posts = [Post]()

                guard let documentSnapshot = documentSnapshot else { return }

                for document in documentSnapshot.documents {

                    do {

                        if let post = try document.data(as: Post.self, decoder: Firestore.Decoder()

                        ) {

                            if let blockList = UserManager.shared.visitorUserInfo?.blockList {

                                if !blockList.contains(post.uid) {

                                    posts.append(post)

                                }

                            } else {

                                posts.append(post)
                            }
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }
                completion(.success(posts))
            }

        default:

            return query.addSnapshotListener { (documentSnapshot, error) in

                if let error = error {

                    completion(.failure(error))

                }

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

    func updatePost(
        postID: String,
        editTime: Int64,
        content: String,
        imageUrl: String?,
        completion: @escaping StatusCompletion
    ) {

        posts.whereField("postID", isEqualTo: postID).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            }

            let targetPost = querySnapshot?.documents.first

            targetPost?.reference.updateData([
                "editTime": editTime,
                "content": content,
                "imageUrl": imageUrl as Any
            ])

            completion(.success("Updated post content"))
        }
    }
}
