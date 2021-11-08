//
//  HashtagManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/30.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class HashtagManager {

    static let shared = HashtagManager()

    private init() {}

    let hashtags = Firestore.firestore().collection("hashtags")

    func checkDuplicateHashtag(
        hashtag: Hashtag,
        postID: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        // check if there's same hashtag in database

        hashtags
            .whereField("title", isEqualTo: hashtag.title)
            .limit(to: 1)
            .getDocuments { querySnapshot, error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    // find same hashtag in database, and update the data

                    if let document = querySnapshot?.documents, !document.isEmpty {

                        let targetHashtag = querySnapshot?.documents.first

                        targetHashtag?.reference.updateData([
                            "postList": FieldValue.arrayUnion([postID]),
                            "postNumber": FieldValue.increment(Int64(1))
                        ])

                        completion(.success("Added post to existing hashtag"))

                    } else {

                        // find no same hashtag in database, and create new one

                        var newHashtag = hashtag

                        self.addHashag(hashtag: &newHashtag) { result in

                            switch result {

                            case .success(let success): print(success)

                            case .failure(let error): print(error)
                            }
                        }
                    }
                }
            }
    }

    func addHashag(hashtag: inout Hashtag, completion: @escaping (Result<String, Error>) -> Void) {

        let document = hashtags.document()

        hashtag.hashtagID = document.documentID

        do {

            _ = try hashtags.addDocument(from: hashtag, encoder: Firestore.Encoder(), completion: { error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    completion(.success("Added new hashtag"))
                }
            })

        } catch {

            completion(.failure(error))
        }
    }

    func fetchHashtag(
        postID: String?,
        completion: @escaping (Result<[Hashtag], Error>) -> Void
    ) {

        if let postID = postID {

            hashtags
                .whereField("postID", isEqualTo: postID)
                .order(by: "postNumber", descending: true)
                .getDocuments { (querySnapshot, error) in

                    if let error = error {

                        completion(.failure(error))

                    } else {

                        var hashtags = [Hashtag]()

                        for document in querySnapshot!.documents {

                            do {

                                if let hashtag = try document.data(as: Hashtag.self, decoder: Firestore.Decoder()
                                ) {

                                    hashtags.append(hashtag)
                                }

                            } catch {

                                completion(.failure(error))
                            }
                        }

                        completion(.success(hashtags))
                    }
                }

        } else {

            hashtags
                .order(by: "postNumber", descending: true)
                .getDocuments { (querySnapshot, error) in

                    if let error = error {

                        completion(.failure(error))

                    } else {

                        var hashtags = [Hashtag]()

                        for document in querySnapshot!.documents {

                            do {

                                if let hashtag = try document.data(as: Hashtag.self, decoder: Firestore.Decoder()
                                ) {

                                    hashtags.append(hashtag)
                                }

                            } catch {

                                completion(.failure(error))
                            }
                        }

                        completion(.success(hashtags))
                    }
                }
        }
    }

    func deletePostFromHashtag(
        hashtag: String,
        postID: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        hashtags.whereField("title", isEqualTo: hashtag)
            .getDocuments { querySnapshot, error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    let targetHashtag = querySnapshot?.documents.first

                    targetHashtag?.reference.updateData([
                        "postList": FieldValue.arrayRemove([postID]),
                        "postNumber": FieldValue.increment(Int64(-1))
                    ])

                    completion(.success("Deleted post from hashtag post list"))
                }
            }
    }
}
