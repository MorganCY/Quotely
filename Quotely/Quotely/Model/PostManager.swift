//
//  PostProvider.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestoreSwift

class PostManager {

    let imagePath = Storage.storage().reference().child("posts")

    let posts = Firestore.firestore().collection("posts")

    func publishPost(post: Post, completion: @escaping (Result<String, Error>) -> Void) {

        let document = posts.document()

        document.setData(post.toDict) { error in

            if let error = error {

                completion(.failure(error))

            } else {

                completion(.success("Success"))
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
                        if let post = try document.data(as: Post.self, decoder: Firestore.Decoder()) {

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
