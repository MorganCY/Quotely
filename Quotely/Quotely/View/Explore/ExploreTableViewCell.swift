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

    override func awakeFromNib() {
        super.awakeFromNib()

        postImageView.contentMode = .scaleAspectFill

        postImageView.cornerRadius = CornerRadius.standard.rawValue

        likeButton.isEnabled = true
    }

    var likeHandler: (() -> Void) = {}

    @IBAction func like(_ sender: UIButton) {

        likeHandler()
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
        let buttonColor: UIColor = hasLiked ? .red : .gray

        likeButton.setImage(buttonImage, for: .normal)
        likeButton.tintColor = buttonColor

        userNameLabel.text = userName
        timeLabel.text = time
        contentLabel.text = content

        if let postImageUrl = postImageUrl {

            // Define postImageView display state in case of wrongly reusing cell
            postImageView.isHidden = false
            postImageView.loadImage(postImageUrl, placeHolder: nil)

        } else {

            postImageView.isHidden = true
        }

        if let userImage = userImage {

            userImageView.image = userImage
            userImageView.cornerRadius = userImageView.frame.width / 2

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
