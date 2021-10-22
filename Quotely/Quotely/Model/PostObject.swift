//
//  PostObject.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation

struct Post: Codable {

    var postID: String?
    var uid: String
    var createdTime: Int64
    var editTime: Int64?
    var content: String
    var imageUrl: String?
    var hashtag: [String]?
    var likeNumber: Int?
    var likeUser: [String]
    var commentNumber: Int?

    var toDict: [String: Any] {

        return [
            "postID": postID as Any,
            "uid": uid as Any,
            "createdTime": createdTime as Any,
            "editTime": editTime as Any,
            "content": content as Any,
            "imageUrl": imageUrl as Any,
            "hashtag": hashtag as Any,
            "likeNumber": likeNumber as Any,
            "likeUser": likeUser as Any,
            "commentNumber": commentNumber as Any
        ]
    }
}
