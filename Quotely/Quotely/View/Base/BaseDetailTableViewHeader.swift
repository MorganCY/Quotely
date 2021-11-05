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
    @IBOutlet weak var userInfoStackView: UIStackView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    var hasUserInfo = false {
        didSet {
            userImageView.isHidden = !hasUserInfo
            userNameLabel.isHidden = !hasUserInfo
            timeLabel.isHidden = !hasUserInfo
        }
    }

    var isEnableEdit = false

    var profileHandler: () -> Void = {}

    var editHandler: () -> Void = {}

    var deleteHandler: () -> Void = {}

    override func awakeFromNib() {
        super.awakeFromNib()

        userImageView.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
        userImageView.isUserInteractionEnabled = true
        userNameLabel.isUserInteractionEnabled = true

        postImageView.contentMode = .scaleAspectFill
        postImageView.cornerRadius = CornerRadius.standard.rawValue
        postImageView.isHidden = true

        editButton.tintColor = .gray
        deleteButton.tintColor = .gray
    }

    func layoutHeader(
        isCard: Bool,
        card: Card?,
        post: Post?,
        postAuthor: User?,
        isAuthor: Bool
    ) {

        switch isCard {

        case true:

            contentLabel.text = "\(card?.content ?? "")\n\n\(card?.author ?? "")"
            postImageView.isHidden = !isAuthor
            timeLabel.isHidden = !isAuthor
            userImageView.isHidden = !isAuthor
            userNameLabel.isHidden = !isAuthor
            timeLabel.isHidden = !isAuthor
            editButton.isHidden = !isAuthor
            deleteButton.isHidden = !isAuthor

        case false:

            contentLabel.text = post?.content
            editButton.isHidden = !isAuthor
            deleteButton.isHidden = !isAuthor

            if let createdTime = post?.createdTime {

                timeLabel.text = Date.fullDateFormatter.string(from: Date.init(milliseconds: createdTime))
            }

            if let userImageUrl = postAuthor?.profileImageUrl,
               let name = postAuthor?.name {

                hasUserInfo = true

                userImageView.loadImage(userImageUrl, placeHolder: nil)
                userNameLabel.text = name

                userImageView.cornerRadius = userImageView.frame.width / 2
            }

            if let postImageUrl = post?.imageUrl {

                postImageView.loadImage(postImageUrl, placeHolder: nil)
                postImageView.isHidden = false

            } else {

                postImageView.isHidden = true
            }
        }
    }

    @IBAction func edit(_ sender: UIButton) {

        editHandler()
    }

    @IBAction func deleteComment(_ sender: UIButton) {

        deleteHandler()
    }
}

extension BaseDetailTableViewHeader:  UIGestureRecognizerDelegate { }
