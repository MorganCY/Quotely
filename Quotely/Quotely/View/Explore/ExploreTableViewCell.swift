//
//  ExploreTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit

class ExploreTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView! {

        didSet {

            postImageView.isHidden = true
        }
    }

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!

    @IBOutlet weak var stackViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var postImageViewHeightAnchor: NSLayoutConstraint!

    override func awakeFromNib() {

        postImageView.contentMode = .scaleAspectFill
    }

    func layoutCell(
        userImage: UIImage?,
        name: String,
        time: String,
        content: String,
        postImage: UIImage?,
        likeNumber: Int?,
        commentNumber: Int?
    ) {

        userNameLabel.text = name
        timeLabel.text = time
        contentLabel.text = content

        if let userImage = userImage {

            profileImageView.image = userImage

        } else {

            profileImageView.image = UIImage.sfsymbol(.person)
        }

        if let postImage = postImage {

            postImageView.image = postImage

            stackViewTopAnchor.constant += postImageView.frame.height

        } else {

            postImageViewHeightAnchor.constant = 0
        }

        if let likeNumber = likeNumber,
           let commentNumber = commentNumber {

            likeButton.setTitle("\(likeNumber)", for: .normal)
            commentButton.setTitle("\(commentNumber)", for: .normal)
        }
    }
}
