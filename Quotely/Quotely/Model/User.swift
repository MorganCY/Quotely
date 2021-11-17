//
//  User.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/28.
//

import Foundation

struct User: Codable {

    // informaiton
    var uid: String
    var name: String
    var profileImageUrl: String?
    var registerTime: Int64?
    var provider: String?

    // follow
    var followingList: [String]?
    var followerList: [String]?
    var blockList: [String]?
    var followingNumber: Int
    var followerNumber: Int
    var blockNumber: Int

    // jornal
    var journalList: [String]?

    // card
    var likeCardList: [String]?
    var dislikeCardList: [String]?

    // post
    var postList: [String]?
    var postNumber: Int

    // default user when no data found

    static let `default` = User(
        uid: "404",
        name: "找不到用戶",
        profileImageUrl: "",
        followingNumber: 0,
        followerNumber: 0,
        blockNumber: 0,
        postNumber: 0
    )
}
