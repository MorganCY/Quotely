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
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editTextField: UITextField!
    @IBOutlet weak var doneEditingButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

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

        userImageView.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true

        editButton.tintColor = .gray
        deleteButton.tintColor = .gray

        contentLabel.isHidden = isEnableEdit
        editTextField.isHidden = !isEnableEdit
        doneEditingButton.isHidden = !isEnableEdit
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
        timeLabel.text = Date.fullDateFormatter.string(from: Date.init(milliseconds: comment.createdTime))
        contentLabel.text = comment.content

        editButton.isHidden = !isAuthor
        deleteButton.isHidden = !isAuthor

        guard let editTime = comment.editTime else { return }

        timeLabel.text = "已編輯 \(Date.fullDateFormatter.string(from: Date.init(milliseconds: editTime)))"
    }

    var editHandler: (String) -> Void = {_ in}

    var deleteHandler: () -> Void = {}

    @IBAction func edit(_ sender: UIButton) {

        isEnableEdit = true
        editTextField.text = contentLabel.text
    }

    @IBAction func doneEditing(_ sender: UIButton) {

        guard let text = editTextField.text else { return }

        editHandler(text)
        contentLabel.text = text
        isEnableEdit = false
    }

    @IBAction func deleteComment(_ sender: UIButton) {

        deleteHandler()
    }
}
