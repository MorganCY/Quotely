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
    @IBOutlet weak var cardStackView: UIStackView!
    @IBOutlet weak var cardTopicView: UIView!
    @IBOutlet weak var cardContentLabel: UILabel!
    @IBOutlet weak var cardAuthorLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        userImageView.clipsToBounds = true
        userImageView.cornerRadius = userImageView.frame.width / 2
        postImageView.cornerRadius = CornerRadius.standard.rawValue
        cardImageView.setSpecificCorner(corners: [.topRight, .bottomRight])
        cardImageView.clipsToBounds = true
    }

    var likeHandler: () -> Void = {}

    @IBAction func like(_ sender: UIButton) { likeHandler() }

    func layoutCell(
        userInfo: User,
        post: Post,
        isLikePost: Bool
    ) {

        let buttonImage: UIImage = isLikePost ? UIImage.sfsymbol(.heartSelected) : UIImage.sfsymbol(.heartNormal)
        let buttonColor: UIColor = isLikePost ? UIColor.M2 : .gray

        if let profileImageUrl = userInfo.profileImageUrl {

            userImageView.loadImage(profileImageUrl, placeHolder: nil)

        } else {

            userImageView.image = UIImage.asset(.logo)
        }

        userNameLabel.text = userInfo.name
        timeLabel.text = Date.init(milliseconds: post.createdTime).timeAgoDisplay()
        contentLabel.text = post.content

        likeButton.setImage(buttonImage, for: .normal)
        likeButton.tintColor = buttonColor
        likeNumberLabel.text = "\(post.likeNumber)"

        if let postImageUrl = post.imageUrl {

            // Define postImageView display state in case of wrongly reusing cell

            postImageView.isHidden = false
            postImageView.loadImage(postImageUrl, placeHolder: nil)

        } else {

            postImageView.isHidden = true
        }

        if let cardContent = post.cardContent,
           let cardAuthor = post.cardAuthor,
           let cardImageUrl = post.imageUrl {

            cardStackView.isHidden = false
            postImageView.isHidden = true

            cardContentLabel.text = cardContent.replacingOccurrences(of: "\\n", with: "\n")
            cardAuthorLabel.text = cardAuthor
            cardImageView.loadImage(cardImageUrl, placeHolder: nil)

        } else {

            cardStackView.isHidden = true
        }

        guard let editTime = post.editTime else { return }

        timeLabel.text = "已編輯 \(Date.init(milliseconds: editTime).timeAgoDisplay())"
    }
}
