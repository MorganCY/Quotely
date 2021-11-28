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

    private init() {}

    static let shared = JournalManager()

    let journals = Firestore.firestore().collection("journals")

    func createJournal(
        journal: inout Journal,
        completion: @escaping StatusCompletion
    ) {

        let document = journals.document()

        journal.journalID = document.documentID
        journal.createdMonth = Date().getCurrentTime(format: .MM)
        journal.createdYear = Date().getCurrentTime(format: .yyyy)

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

    func fetchJournal(
        month: String,
        year: String,
        completion: @escaping (Result<[Journal], Error>) -> Void
    ) {

        journals
            .whereField("uid", isEqualTo: UserManager.shared.visitorUserInfo?.uid ?? "")
            .whereField("createdMonth", isEqualTo: month)
            .whereField("createdYear", isEqualTo: year)
            .order(by: "createdTime", descending: true)
            .getDocuments { (querySnapshot, error) in

                if let error = error {

                    completion(.failure(error))
                }

                var journals = [Journal]()

                guard let querySnapshot = querySnapshot else { return }

                for document in querySnapshot.documents {

                    do {

                        if let journal = try document.data(as: Journal.self, decoder: Firestore.Decoder()
                        ) {

                            journals.append(journal)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(journals))
            }
    }
}
