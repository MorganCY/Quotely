//
//  BaseDetailCommentCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/20.
//

import Foundation
import UIKit

class PostDetailCommentCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editTextField: UITextField!
    @IBOutlet weak var doneEditingButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var optionMenuButton: UIButton!

    var isEnableEdit = false {
        didSet {
            contentLabel.isHidden = isEnableEdit
            editTextField.isHidden = !isEnableEdit
            doneEditingButton.isHidden = !isEnableEdit
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = .clear

        userImageView.clipsToBounds = true

        editButton.tintColor = .gray
        deleteButton.tintColor = .gray

        contentLabel.isHidden = isEnableEdit
        editTextField.isHidden = !isEnableEdit
        doneEditingButton.isHidden = !isEnableEdit
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.cornerRadius = userImageView.frame.width / 2
    }

    func layoutCell(
        comment: Comment,
        userImageUrl: String?,
        userName: String,
        isAuthor: Bool
    ) {

        if let profileImageUrl = userImageUrl {

            userImageView.loadImage(profileImageUrl, placeHolder: nil)

        } else {

            userImageView.image = UIImage.asset(.logo)
        }

        nameLabel.text = userName
        timeLabel.text = Date.init(milliseconds: comment.createdTime).timeAgoDisplay()
        contentLabel.text = comment.content

        editButton.isHidden = !isAuthor
        deleteButton.isHidden = !isAuthor
        optionMenuButton.isHidden = isAuthor

        guard let editTime = comment.editTime else { return }

        timeLabel.text = "已編輯 \(Date.init(milliseconds: editTime).timeAgoDisplay())"
    }

    var editHandler: (String) -> Void = {_ in}

    var deleteHandler: () -> Void = {}

    var optionHandler: () -> Void = {}

    @IBAction func edit(_ sender: UIButton) {

        isEnableEdit = true
        editTextField.text = contentLabel.text
    }

    @IBAction func doneEditing(_ sender: UIButton) {

        isEnableEdit = false

        guard let text = editTextField.text else { return }

        if text != contentLabel.text {

            editHandler(text)
            contentLabel.text = text
        }
    }

    @IBAction func deleteComment(_ sender: UIButton) {

        deleteHandler()
    }

    @IBAction func tapOptionMenuButton(_ sender: UIButton) {

        optionHandler()
    }
}
