//
//  JournalObject.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/26.
//

import Foundation

struct Journal: Codable {

    var uid: String
    var createdTime: Int64
    var createdMonth: String?
    var createdYear: String?
    var emoji: String
    var content: String
    var journalID: String?
}
