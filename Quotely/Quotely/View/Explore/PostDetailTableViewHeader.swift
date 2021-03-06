//
//  BaseDetailTableViewHeader.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation
import UIKit

protocol PostDetailTableViewHeaderDelegate: AnyObject {

    func likePostHeader(_ header: PostDetailTableViewHeader)
    func editPostHeader(_ header: PostDetailTableViewHeader)
    func deletePost(_ header: PostDetailTableViewHeader)
    func optionMenuOfPost(_ header: PostDetailTableViewHeader)
}

class PostDetailTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var userStackView: UIStackView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var cardStackView: UIStackView!
    @IBOutlet weak var cardContentLabel: UILabel!
    @IBOutlet weak var cardAuthorLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var optionMenuButton: UIButton!

    weak var delegate: PostDetailTableViewHeaderDelegate?

    var hasUserInfo = false {
        didSet {
            userImageView.isHidden = !hasUserInfo
            userNameLabel.isHidden = !hasUserInfo
            timeLabel.isHidden = !hasUserInfo
        }
    }

    var isEnableEdit = false

    @IBAction func tapLikeButton(_ sender: UIButton) {
        delegate?.likePostHeader(self)
    }

    @IBAction func tapEditButton(_ sender: UIButton) {
        delegate?.editPostHeader(self)
    }

    @IBAction func tapDeleteButton(_ sender: UIButton) {
        delegate?.deletePost(self)
    }

    @IBAction func tapOptionMenuButton(_ sender: UIButton) {
        delegate?.optionMenuOfPost(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        userImageView.clipsToBounds = true
        userImageView.isUserInteractionEnabled = true
        userNameLabel.isUserInteractionEnabled = true

        postImageView.contentMode = .scaleAspectFill
        postImageView.cornerRadius = CornerRadius.standard.rawValue
        postImageView.isHidden = true

        editButton.tintColor = .gray
        deleteButton.tintColor = .gray

        likeButton.isUserInteractionEnabled = true

        cardImageView.setSpecificCorner(corners: [.topRight, .bottomRight])

        cardImageView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.cornerRadius = userImageView.frame.width / 2
    }

    func layoutHeader(
        post: Post?,
        postAuthor: User?,
        isAuthor: Bool,
        isLike: Bool
    ) {

        let buttonImage: UIImage = isLike ? UIImage.sfsymbol(.heartSelected) : UIImage.sfsymbol(.heartNormal)
        let buttonColor: UIColor = isLike ? UIColor.M2 : .gray

        likeButton.setImage(buttonImage, for: .normal)
        likeButton.tintColor = buttonColor

        contentLabel.text = post?.content
        editButton.isHidden = !isAuthor
        deleteButton.isHidden = !isAuthor
        optionMenuButton.isHidden = isAuthor
        likeNumberLabel.text = "\(post?.likeNumber ?? 0)"

        if let createdTime = post?.createdTime {

            timeLabel.text = Date.init(milliseconds: createdTime).timeAgoDisplay()
        }

        if let profileImageUrl = postAuthor?.profileImageUrl {

            userImageView.loadImage(profileImageUrl, placeHolder: nil)

        } else {

            userImageView.image = UIImage.asset(.logo)
        }

        if let name = postAuthor?.name {

            hasUserInfo = true

            userNameLabel.text = name
        }

        if let postImageUrl = post?.imageUrl {

            postImageView.loadImage(postImageUrl, placeHolder: nil)
            postImageView.isHidden = false

        } else {

            postImageView.isHidden = true
        }

        if let cardContent = post?.cardContent,
           let cardAuthor = post?.cardAuthor,
           let cardImageUrl = post?.imageUrl {

            cardStackView.isHidden = false
            postImageView.isHidden = true

            cardContentLabel.text = cardContent.replacingOccurrences(of: "\\n", with: "\n")
            cardAuthorLabel.text = cardAuthor
            cardImageView.loadImage(cardImageUrl, placeHolder: nil)

        } else {

            cardStackView.isHidden = true
        }

        guard let editTime = post?.editTime else { return }

        timeLabel.text = "????????? \(Date.init(milliseconds: editTime).timeAgoDisplay())"
    }
}
