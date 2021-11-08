//
//  User.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/28.
//

import Foundation

struct User: Codable {

    var uid: String
    var name: String?
    var saying: String?
    var registerTime: Int64?
    var provider: String?
    var postList: [String]?
    var likeCardID: [String]?
    var dislikeCardID: [String]?
    var journalID: [String]?
    var following: [String]?
    var follower: [String]?
    var blocklist: [String]?
    var followingNumber: Int
    var followerNumber: Int
    var postNumber: Int
    var profileImageUrl: String?

    // default user when no data found

    static let `default` = User(uid: "404", name: "找不到用戶", followingNumber: 0, followerNumber: 0, postNumber: 0)
}
