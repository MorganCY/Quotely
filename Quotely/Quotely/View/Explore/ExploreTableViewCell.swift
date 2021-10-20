//
//  ExploreTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import Kingfisher

class ExploreTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!

    var hasUserInfo = false {

        didSet {

            postImageView.isHidden = !hasUserInfo
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        postImageView.contentMode = .scaleAspectFill

        postImageView.layer.cornerRadius = 10
    }

    func layoutCell(
        userImage: UIImage?,
        userName: String,
        time: String,
        content: String,
        imageUrl: String?,
        likeNumber: Int?,
        commentNumber: Int?
    ) {

        userNameLabel.text = userName
        timeLabel.text = time
        contentLabel.text = content

        if let imageUrl = imageUrl {

            hasUserInfo = true

            postImageView.loadImage(imageUrl, placeHolder: nil)
        }

        if let userImage = userImage {

            userImageView.image = userImage

        } else {

            userImageView.image = UIImage.sfsymbol(.person)
        }

        if let likeNumber = likeNumber,
           let commentNumber = commentNumber {

            likeButton.setTitle("\(likeNumber)", for: .normal)
            commentButton.setTitle("\(commentNumber)", for: .normal)
        }
    }
}
