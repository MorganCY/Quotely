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
        createdMonth: String = Date().getCurrentTime(format: .MM),
        createdYear: String = Date().getCurrentTime(format: .yyyy),
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let document = journals.document()

        journal.journalID = document.documentID
        journal.createdMonth = createdMonth
        journal.createdYear = createdYear

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
        uid: String,
        month: String,
        year: String,
        completion: @escaping (Result<[Journal], Error>) -> Void
    ) {

        journals
            .whereField("uid", isEqualTo: uid)
            .whereField("createdMonth", isEqualTo: month)
            .whereField("createdYear", isEqualTo: year)
            .order(by: "createdTime", descending: true)
            .getDocuments { (querySnapshot, error) in

                if let error = error {

                    completion(.failure(error))

                } else {

                    var journals = [Journal]()

                    for document in querySnapshot!.documents {

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

    func deleteJournal(
        journalID: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        journals.whereField("journalID", isEqualTo: journalID).getDocuments { querySnapshot, error in

            if let error = error {

                completion(.failure(error))

            } else {

                let targetPost = querySnapshot?.documents.first

                targetPost?.reference.delete()

                completion(.success("Deleted journal"))
            }
        }
    }
}
