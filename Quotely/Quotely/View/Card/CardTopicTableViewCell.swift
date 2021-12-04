//
//  CardTopicTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/9.
//

import Foundation
import UIKit

class CardTopicTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var optionMenuButton: UIButton!

    var optionHandler: () -> Void = {}

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.cornerRadius = userImageView.frame.width / 2
    }

    @IBAction func tapOptionButton(_ sender: UIButton) {

        optionHandler()
    }

    func layoutCell(user: User, post: Post) {

        if user.uid == UserManager.shared.visitorUserInfo?.uid {
            optionMenuButton.isHidden = true
        } else {
            optionMenuButton.isHidden = false
        }

        if let userImageUrl = user.profileImageUrl {
            userImageView.loadImage(userImageUrl, placeHolder: nil)
        } else {
            userImageView.image = UIImage.asset(.logo)
        }

        if let editTime = post.editTime {
            timeLabel.text = "已編輯 \(Date.init(milliseconds: editTime).timeAgoDisplay())"
        }

        userNameLabel.text = user.name
        timeLabel.text = Date.init(milliseconds: post.createdTime).timeAgoDisplay()
        contentLabel.text = post.content
    }
}
