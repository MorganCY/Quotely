//
//  ProfileTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/3.
//

import Foundation
import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!

    override func awakeFromNib() {

        postImageView.cornerRadius = CornerRadius.standard.rawValue * 2 / 3
    }

    func layoutCell(post: Post) {

        contentLabel.text = post.content
        timeLabel.text = Date.fullDateFormatter.string(from: Date.init(milliseconds: post.createdTime))

        if let imageUrl = post.imageUrl {

            postImageView.isHidden = false
            postImageView.loadImage(imageUrl, placeHolder: nil)

        } else if post.imageUrl == nil {

            postImageView.isHidden = true
        }

        if let editTime = post.editTime {

            timeLabel.text = "已編輯 \(Date.fullDateFormatter.string(from: Date.init(milliseconds: editTime)))"
        }

    }
}
