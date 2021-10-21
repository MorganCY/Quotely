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

//    var clickLike: (() -> Void) = {}
//
//    @IBAction func clickLike(_ sender: UIButton) {
//
//        clickLike()
//    }

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
        imageUrl: String?,
        likeNumber: Int?,
        commentNumber: Int?
    ) {

        userNameLabel.text = userName
        timeLabel.text = time
        contentLabel.text = content

        if let imageUrl = imageUrl {

            postImageView.loadImage(imageUrl, placeHolder: nil)
            postImageView.isHidden = false
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
