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

    var editHandler: () -> Void = {}

    var deleteHandler: () -> Void = {}

    override func awakeFromNib() {
        super.awakeFromNib()

        postImageView.contentMode = .scaleAspectFill
        postImageView.cornerRadius = CornerRadius.standard.rawValue
        postImageView.isHidden = true

        editButton.tintColor = .gray
        deleteButton.tintColor = .gray
    }

    func layoutHeader(
        userImage: UIImage?,
        userName: String?,
        time: Int64?,
        content: String,
        imageUrl: String?,
        isAuthor: Bool
    ) {

        contentLabel.text = content
        editButton.isHidden = !isAuthor
        deleteButton.isHidden = !isAuthor

        if let userImage = userImage,
           let name = userName,
           let time = time {

            hasUserInfo = true

            userImageView.image = userImage
            userNameLabel.text = name
            timeLabel.text = Date.fullDateFormatter.string(from: Date.init(milliseconds: time))

            userImageView.cornerRadius = userImageView.frame.width / 2
        }

        if let imageUrl = imageUrl {

            postImageView.loadImage(imageUrl, placeHolder: nil)
            postImageView.isHidden = false
        }
    }

    @IBAction func edit(_ sender: UIButton) {

        editHandler()
    }

    @IBAction func deleteComment(_ sender: UIButton) {

        deleteHandler()
    }
}
