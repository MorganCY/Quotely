//
//  CardObject.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/24.
//

import Foundation

struct Card: Codable {

    var cardID: String?
    var content: String
    var author: String
    var likeNumber: Int
    var likeUser: [String]
    var dislikeUser: [String]
    var postList: [String]?
}
