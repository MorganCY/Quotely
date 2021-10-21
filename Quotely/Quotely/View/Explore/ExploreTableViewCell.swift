//
//  ExploreTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import Kingfisher

protocol ExploreTableViewCellDelegate: AnyObject {

    func getTableViewCell(_ cell: ExploreTableViewCell)
}

class ExploreTableViewCell: UITableViewCell {

    weak var delegate: ExploreTableViewCellDelegate?

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        postImageView.contentMode = .scaleAspectFill

        postImageView.cornerRadius = CornerRadius.standard.rawValue

        postImageView.isHidden = true

        likeButton.isEnabled = true
    }

    func layoutCell(
        userImage: UIImage?,
        userName: String,
        time: String,
        content: String,
        postImageUrl: String?,
        likeNumber: Int?,
        commentNumber: Int?,
        hasLiked: Bool
    ) {

        let buttonImage: UIImage = hasLiked ? UIImage.sfsymbol(.heartSelected)! : UIImage.sfsymbol(.heartNormal)!
        let buttonColor: UIColor = hasLiked ?  .red : .gray

        likeButton.setBackgroundImage(buttonImage, for: .normal)
        likeButton.tintColor = buttonColor

        userNameLabel.text = userName
        timeLabel.text = time
        contentLabel.text = content

        if let userImage = userImage {

            userImageView.image = userImage
            userImageView.cornerRadius = userImageView.frame.width / 2

        } else {

            userImageView.image = UIImage.sfsymbol(.person)
        }

        if let postImageUrl = postImageUrl {

            postImageView.loadImage(postImageUrl, placeHolder: nil)
            postImageView.isHidden = false
        }

        if let likeNumber = likeNumber,
           let commentNumber = commentNumber {

            likeButton.setTitle("\(likeNumber)", for: .normal)
            commentButton.setTitle("\(commentNumber)", for: .normal)
        }
    }
}
