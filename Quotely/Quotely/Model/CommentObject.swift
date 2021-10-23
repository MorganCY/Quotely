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
}
