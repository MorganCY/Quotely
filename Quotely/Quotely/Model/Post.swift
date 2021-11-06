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
    var hashtag: String?
    var likeNumber: Int
    var likeUser: [String]?
    var commentNumber: Int?
}
