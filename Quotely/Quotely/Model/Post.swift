//
//  PostObject.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation

struct Post: Codable, Equatable {
    var postID: String?
    var uid: String
    var createdTime: Int64
    var editTime: Int64?
    var content: String
    var imageUrl: String?
    var likeNumber: Int
    var commentNumber: Int
    var likeUser: [String]?

    // card information
    var cardID: String?
    var cardContent: String?
    var cardAuthor: String?

    static let `default` = Post(uid: "404", createdTime: 0, content: "找不到內容", likeNumber: 404, commentNumber: 404)
}
