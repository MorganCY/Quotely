//
//  CommentObject.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation

struct Comment: Codable {

    var uid: String
    var createdTime: Int64
    var editTime: Int64?
    var content: String
    var postID: String?
    var cardCommentID: String?
    var postCommentID: String?
}

// Custom initializer
extension Comment {

    init(content: String,
         postID: String?
    ) {
        self.uid = UserManager.shared.visitorUserInfo?.uid ?? ""
        self.createdTime = Date().millisecondsSince1970
        self.editTime = nil
        self.content = content
        self.postID = postID
    }
}
