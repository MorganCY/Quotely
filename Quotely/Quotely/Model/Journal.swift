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

// Custom initializer
extension Journal {

    init(createdMonth: String?,
         createdYear: String?,
         emoji: String,
         content: String
    ) {
        self.uid = UserManager.shared.visitorUserInfo?.uid ?? ""
        self.createdTime = Date().millisecondsSince1970
        self.createdMonth = createdMonth
        self.createdYear = createdYear
        self.emoji = emoji
        self.content = content
    }
}
