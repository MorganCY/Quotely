//
//  ProfileTableViewHeaderView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/4.
//

import Foundation
import UIKit

class ProfileTableViewHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postNumberLabel: UILabel!
    @IBOutlet weak var followerNumberLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var followButton: UIButton!

    override func awakeFromNib() {

        profileImageView.cornerRadius = profileImageView.frame.width / 2

        blockButton.cornerRadius = CornerRadius.standard.rawValue * 2 / 3
        blockButton.borderColor = .gray
        blockButton.borderWidth = 1
        followButton.cornerRadius = CornerRadius.standard.rawValue * 2 / 3
        followButton.borderColor = .gray
        followButton.borderWidth = 1
    }

    func layoutHeader(userInfo: User) {

        profileImageView.image = UIImage.asset(.testProfile)
        userNameLabel.text = userInfo.name
        postNumberLabel.text = "\(userInfo.postNumber) 則想法"
        followerNumberLabel.text = "\(userInfo.followerNumber) 被追蹤"
        followingNumberLabel.text = "\(userInfo.followingNumber) 追蹤中"
    }
}
