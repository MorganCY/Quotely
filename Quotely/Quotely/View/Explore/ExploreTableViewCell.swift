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
    @IBOutlet weak var userInfoStackView: UIStackView!
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true

        postImageView.contentMode = .scaleAspectFill
        postImageView.cornerRadius = CornerRadius.standard.rawValue

        hashtagLabel.cornerRadius = CornerRadius.standard.rawValue / 3
        hashtagLabel.layer.masksToBounds = true

        likeButton.isEnabled = true
    }

    var likeHandler: () -> Void = {}

    @IBAction func like(_ sender: UIButton) {

        likeHandler()
    }

    func layoutCell(
        userImageUrl: String,
        userName: String,
        post: Post,
        hasLiked: Bool
    ) {

        let buttonImage: UIImage = hasLiked ? UIImage.sfsymbol(.heartSelected)! : UIImage.sfsymbol(.heartNormal)!
        let buttonColor: UIColor = hasLiked ? UIColor.M2! : .gray

        likeButton.setImage(buttonImage, for: .normal)
        likeButton.tintColor = buttonColor

        userNameLabel.text = userName
        timeLabel.text = Date.fullDateFormatter.string(from: Date.init(milliseconds: post.createdTime))
        contentLabel.text = post.content

        userImageView.loadImage(userImageUrl, placeHolder: nil)
        userImageView.cornerRadius = userImageView.frame.width / 2

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

        } else if post.imageUrl == nil {

            postImageView.isHidden = true
        }

        likeNumberLabel.text = "\(post.likeNumber ?? 0)"
    }
}
