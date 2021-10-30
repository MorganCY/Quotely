//
//  Hashtag.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/30.
//

import Foundation

struct Hashtag: Codable {

    var hashtagID: String?
    var title: String
    var newPostID: String
    var postList: [String]?
    var postNumber: Int?
}
