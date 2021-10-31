//
//  CardProvider.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/24.
//

import Foundation
import FirebaseFirestore

class CardManager {

    static let shared = CardManager()

    private init() {}

    let cards = Firestore.firestore().collection("cards")

    func fetchRandomCards(limitNumber: Int, completion: @escaping (Result<[Card], Error>) -> Void) {

        let randomID = cards.document().documentID

        cards
            .whereField("cardID", isGreaterThanOrEqualTo: randomID)
            .limit(to: limitNumber)
            .getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            } else {

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
    }

    func fetchFavoriteCard(cardID: String, completion: @escaping (Result<Card, Error>) -> Void) {

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

    func updateCards(
        cardID: String,
        likeAction: LikeAction,
        uid: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        cards.whereField("cardID", isEqualTo: cardID).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetCard = querySnapshot?.documents.first

                switch likeAction {

                case .like:

                    targetCard?.reference.updateData([
                        "likeNumber": FieldValue.increment(Int64(likeAction.rawValue)),
                        "likeUser": FieldValue.arrayUnion(["test123456"]),
                        "dislikeUser": FieldValue.arrayRemove(["test123456"])
                    ])

                case .dislike:

                    targetCard?.reference.updateData([
                        "likeNumber": FieldValue.increment(Int64(likeAction.rawValue)),
                        "dislikeUser": FieldValue.arrayUnion(["test123456"]),
                        "likeUser": FieldValue.arrayRemove(["test123456"])
                    ])
                }

                completion(.success("Card was updated"))
            }
        }
    }
}
