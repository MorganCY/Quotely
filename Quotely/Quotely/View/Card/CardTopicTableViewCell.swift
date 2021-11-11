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

    func layoutCell(user: User, post: Post) {

        if let userImageUrl = user.profileImageUrl {

            userImageView.loadImage(userImageUrl, placeHolder: nil)

        } else {

            userImageView.image = UIImage.asset(.logo)
        }

        userImageView.cornerRadius = userImageView.frame.width / 2

        userNameLabel.text = user.name
        timeLabel.text = Date.fullDateFormatter.string(from: Date.init(milliseconds: post.createdTime))
        contentLabel.text = post.content

        guard let editTime = post.editTime else { return }

        timeLabel.text = "已編輯 \(Date.fullDateFormatter.string(from: Date.init(milliseconds: editTime)))"
    }

}
