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
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        userImageView.clipsToBounds = true

        postImageView.cornerRadius = CornerRadius.standard.rawValue

        hashtagLabel.cornerRadius = CornerRadius.standard.rawValue / 3
        hashtagLabel.layer.masksToBounds = true
    }

    var likeHandler: () -> Void = {}

    @IBAction func like(_ sender: UIButton) {

        likeHandler()
    }

    func layoutCell(
        userInfo: User,
        post: Post,
        isLikePost: Bool
    ) {

        let buttonImage: UIImage = isLikePost ? UIImage.sfsymbol(.heartSelected)! : UIImage.sfsymbol(.heartNormal)!
        let buttonColor: UIColor = isLikePost ? UIColor.M2! : .gray

        userImageView.loadImage(userInfo.profileImageUrl ?? "", placeHolder: nil)
        userImageView.cornerRadius = userImageView.frame.width / 2

        userNameLabel.text = userInfo.name
        timeLabel.text = Date.fullDateFormatter.string(from: Date.init(milliseconds: post.createdTime))
        contentLabel.text = post.content

        likeButton.setImage(buttonImage, for: .normal)
        likeButton.tintColor = buttonColor
        likeNumberLabel.text = "\(post.likeNumber ?? 0)"

        if let hashtag = post.hashtag {

            hashtagLabel.isHidden = false
            hashtagLabel.text = hashtag

        } else if post.hashtag == "" {

            hashtagLabel.isHidden = true
        }

        if let postImageUrl = post.imageUrl {

            // Define postImageView display state in case of wrongly reusing cell

            postImageView.isHidden = false
            postImageView.loadImage(postImageUrl, placeHolder: nil)

        } else {

            postImageView.isHidden = true
        }
    }
}
