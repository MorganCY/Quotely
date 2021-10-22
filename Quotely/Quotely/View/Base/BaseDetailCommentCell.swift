//
//  BaseDetailCommentCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation
import UIKit

class BaseDetailCommentCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = .clear

        userImageView.cornerRadius = userImageView.frame.width / 2
    }

    func layoutCell(
        userImage: UIImage,
        userName: String,
        time: String,
        content: String
    ) {

        userImageView.image = userImage
        nameLabel.text = userName
        timeLabel.text = time
        contentLabel.text = content
    }
}
