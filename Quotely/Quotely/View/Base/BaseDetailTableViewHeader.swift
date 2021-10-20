//
//  BaseDetailTableViewHeader.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation
import UIKit

class BaseDetailTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!

    var hasUserInfo = false {

        didSet {

            userImageView.isHidden = !hasUserInfo
            userNameLabel.isHidden = !hasUserInfo
            timeLabel.isHidden = !hasUserInfo
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        postImageView.contentMode = .scaleAspectFill
        postImageView.layer.cornerRadius = 10
        postImageView.isHidden = true
    }

    func layoutHeader(
        userImage: UIImage?,
        userName: String?,
        time: Int64?,
        content: String,
        imageUrl: String?
    ) {

        contentLabel.text = content

        if let userImage = userImage,
           let name = userName,
           let time = time {

            hasUserInfo = true

            userImageView.image = userImage
            userNameLabel.text = name
            timeLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: time))
        }

        if let imageUrl = imageUrl {

            postImageView.loadImage(imageUrl, placeHolder: nil)
            postImageView.isHidden = false
        }
    }
}
