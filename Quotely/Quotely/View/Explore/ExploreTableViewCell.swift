//
//  ExploreTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import Kingfisher
import SwiftUI

class ExploreTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!

    override func awakeFromNib() {

        postImageView.contentMode = .scaleAspectFill

        postImageView.layer.cornerRadius = 10

        postImageView.isHidden = true
    }

    func layoutCell(
        userImage: UIImage?,
        name: String,
        time: String,
        content: String,
        imageUrl: String?,
        likeNumber: Int?,
        commentNumber: Int?
    ) {

        userNameLabel.text = name
        timeLabel.text = time
        contentLabel.text = content

        if let imageUrl = imageUrl {

            postImageView.loadImage(imageUrl, placeHolder: nil)
            postImageView.isHidden = false
        }

        if let userImage = userImage {

            profileImageView.image = userImage

        } else {

            profileImageView.image = UIImage.sfsymbol(.person)
        }

        if let likeNumber = likeNumber,
           let commentNumber = commentNumber {

            likeButton.setTitle("\(likeNumber)", for: .normal)
            commentButton.setTitle("\(commentNumber)", for: .normal)
        }
    }
}
