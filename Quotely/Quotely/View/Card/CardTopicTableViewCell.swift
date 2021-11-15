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

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.clipsToBounds = true
        backgroundColor = .white.withAlphaComponent(0.7)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.cornerRadius = userImageView.frame.width / 2
    }

    func layoutCell(user: User, post: Post) {

        if let userImageUrl = user.profileImageUrl {

            userImageView.loadImage(userImageUrl, placeHolder: nil)

        } else {

            userImageView.image = UIImage.asset(.logo)
        }

        userNameLabel.text = user.name
        timeLabel.text = Date.init(milliseconds: post.createdTime).timeAgoDisplay()
        contentLabel.text = post.content

        guard let editTime = post.editTime else { return }

        timeLabel.text = "已編輯 \(Date.init(milliseconds: editTime).timeAgoDisplay())"
    }

}
