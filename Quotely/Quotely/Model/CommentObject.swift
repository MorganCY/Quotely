//
//  CommentObject.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation

struct Comment: Codable {

    var uid: String
    var content: String
    var createdTime: Int64
    var editTime: Int64?
    var articleID: String?
    var postID: String?
    var postCommentID: String?

    var toDict: [String: Any] {

        return [
            "uid": uid as Any,
            "createdTime": createdTime as Any,
            "editTime": editTime as Any,
            "content": content as Any,
            "articleID": articleID as Any,
            "postID": postID as Any,
            "postCommentID": postCommentID as Any
        ]
    }
}
