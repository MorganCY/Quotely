//
//  HashtagManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/30.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class HashtagManager {

    static let shared = HashtagManager()

    private init() {}

    let hashtags = Firestore.firestore().collection("hashtags")

    func addHashtag(
        hashtag: inout Hashtag,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let document = hashtags.document()

        hashtag.hashtagID = document.documentID
        hashtag.postNumber += 1

        do {

            _ = try hashtags.addDocument(from: hashtag, encoder: Firestore.Encoder(), completion: { error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    completion(.success("Added hashtag"))
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
}
