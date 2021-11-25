//
//  CardProvider.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/24.
//

import Foundation
import FirebaseFirestore

class CardManager {

    private init() {}

    static let shared = CardManager()

    let cards = Firestore.firestore().collection("cards")

    func fetchRandomCards(
        limitNumber: Int,
        completion: @escaping (Result<[Card], Error>) -> Void
    ) {

        let randomID = cards.document().documentID

        cards
            .whereField("cardID", isGreaterThanOrEqualTo: randomID)
            .limit(to: limitNumber)
            .getDocuments { (querySnapshot, error) in

                if let error = error {

                    completion(.failure(error))
                }

                var cards = [Card]()

                for document in querySnapshot!.documents {

                    do {
                        if let card = try document.data(as: Card.self, decoder: Firestore.Decoder()
                        ) {

                            cards.append(card)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(cards))
            }
    }

    func fetchSpecificCard(
        cardID: String,
        completion: @escaping (Result<Card, Error>) -> Void
    ) {

        let reference = cards.document(cardID)

        reference.getDocument { document, error in

            if let document = document, document.exists {

                do {

                    if let card = try document.data(
                        as: Card.self
                    ) {

                        completion(.success(card))
                    }

                } catch {

                    completion(.failure(error))
                }
            }
        }
    }

    func updateCardPostList(
        cardID: String,
        postID: String,
        completion: @escaping StatusCompletion
    ) {

        cards.whereField("cardID", isEqualTo: cardID).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            }

            let targetCard = querySnapshot?.documents.first

            targetCard?.reference.updateData([
                "postList": FieldValue.arrayUnion([postID])
            ])

            completion(.success("Card was updated"))
        }
    }

    func deletePostFromCard(
        postID: String,
        completion: @escaping StatusCompletion
    ) {

        cards.whereField("postList", arrayContains: postID).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            }

            let targetCard = querySnapshot?.documents.first

            targetCard?.reference.updateData([
                "postList": FieldValue.arrayRemove([postID])
            ])

            completion(.success("Post was deleted from card"))
        }
    }
}
