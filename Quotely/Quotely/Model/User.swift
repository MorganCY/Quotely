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
    var postID: [String]?
    var likeCardID: [String]?
    var dislikeCardID: [String]?
    var journalID: [String]?
    var following: [String]?
    var follower: [String]?
    var blocklist: [String]?
    var followingNumber: Int
    var followerNumber: Int
    var postNumber: Int
}
