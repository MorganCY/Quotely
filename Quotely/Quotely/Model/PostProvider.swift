//
//  PostProvider.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import FirebaseFirestore

class PostProvider {

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
}
