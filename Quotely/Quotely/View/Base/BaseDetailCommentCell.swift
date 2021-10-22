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

    var isEnableEdit = false

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = .clear

        userImageView.cornerRadius = userImageView.frame.width / 2

        editButton.tintColor = .gray
        deleteButton.tintColor = .gray
    }

    func layoutCell(
        userImage: UIImage,
        userName: String,
        time: String,
        content: String,
        isAuthor: Bool,
        editTime: String?
    ) {

        userImageView.image = userImage
        nameLabel.text = userName
        timeLabel.text = time
        contentLabel.text = content

        contentLabel.isHidden = isEnableEdit
        editButton.isHidden = !isAuthor
        editTextField.isHidden = !isEnableEdit
        doneEditingButton.isHidden = !isEnableEdit
        deleteButton.isHidden = !isAuthor

        guard let editTime = editTime else { return }

        timeLabel.text = "已編輯 \(editTime)"
    }

    var editHandler: (String) -> Void = {_ in}

    var deleteHandler: () -> Void = {}

    @IBAction func edit(_ sender: UIButton) {

        isEnableEdit = true
        editTextField.text = contentLabel.text
        contentLabel.isHidden = isEnableEdit
        editTextField.isHidden = !isEnableEdit
        doneEditingButton.isHidden = !isEnableEdit
    }

    @IBAction func doneEditing(_ sender: UIButton) {

        guard let text = editTextField.text else { return }

        editHandler(text)
        contentLabel.text = text
        isEnableEdit.toggle()

        editTextField.isHidden = !isEnableEdit
        doneEditingButton.isHidden = !isEnableEdit
    }

    @IBAction func deleteComment(_ sender: UIButton) {

        deleteHandler()
    }
}
