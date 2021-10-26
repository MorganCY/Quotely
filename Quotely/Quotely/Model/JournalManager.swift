//
//  JournalManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class JournalManager {

    static let shared = JournalManager()

    private init() {}

    let journals = Firestore.firestore().collection("journals")

    func addJournal(
        journal: inout Journal,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let document = journals.document()

        journal.journalID = document.documentID

        do {

            _ = try journals.addDocument(from: journal, encoder: Firestore.Encoder(), completion: { error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    completion(.success("Added journal"))
                }
            })

        } catch {

            completion(.failure(error))
        }
    }

}
