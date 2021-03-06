//
//  BlockListTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/11.
//

import Foundation
import UIKit

class BlockListTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    @IBOutlet weak var userInfoStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill

        unblockButton.cornerRadius = CornerRadius.standard.rawValue
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.cornerRadius = userImageView.frame.width / 2
    }

    var unblockHandler: () -> Void = {}

    @IBAction private func tapUnblockButton(_ sender: UIButton) {

        unblockHandler()
    }

    func layoutCell(user: User) {

        if let profileImageUrl = user.profileImageUrl {

            userImageView.loadImage(profileImageUrl, placeHolder: nil)

        } else {

            userImageView.image = UIImage.asset(.logo)
        }

        userNameLabel.text = user.name
    }
}
