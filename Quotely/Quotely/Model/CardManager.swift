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

    func fetchCards(completion: @escaping (Result<[Card], Error>) -> Void) {

        let randomID = cards.document().documentID

        cards
            .whereField("cardID", isGreaterThanOrEqualTo: randomID)
            .limit(to: 3)
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
}
