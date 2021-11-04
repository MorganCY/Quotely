//
//  ProfileTableViewHeaderView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/4.
//

import Foundation
import UIKit

class ProfileTableViewHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var editImageButton: UIButton!

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var editNameButton: UIButton!
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var doneEditNameButton: UIButton!

    @IBOutlet weak var postNumberLabel: UILabel!
    @IBOutlet weak var followerNumberLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var followButton: UIButton!

    var isEnableEdit = false {
        didSet {

            userNameLabel.isHidden = isEnableEdit
            editNameButton.isHidden = isEnableEdit
            editNameTextField.isHidden = !isEnableEdit
            doneEditNameButton.isHidden = !isEnableEdit
        }
    }

    override func awakeFromNib() {

        setupProfileImage()
        setupButtons()

        userNameLabel.isHidden = isEnableEdit
        editNameButton.isHidden = isEnableEdit
        editNameTextField.isHidden = !isEnableEdit
        doneEditNameButton.isHidden = !isEnableEdit
    }

    var editImageHandler: () -> Void = {}
    var editNameHandler: ((String) -> Void) = {_ in }
    var followHandler: (() -> Void) = {}

    @IBAction func editImage(_ sender: UIButton) {

        editImageHandler()
    }

    @IBAction func editName(_ sender: UIButton) {

        isEnableEdit = true

        editNameTextField.text = userNameLabel.text
    }

    @IBAction func doneEditing(_ sender: UIButton) {

        guard let text = editNameTextField.text else { return }

        editNameHandler(text)
        userNameLabel.text = text
        isEnableEdit = false
    }

    @IBAction func follow(_ sender: UIButton) {

        followHandler()
    }

    func layoutHeader(userInfo: User) {

        profileImageView.loadImage(userInfo.profileImageUrl ?? "", placeHolder: nil)
        profileImageView.borderColor = .white
        profileImageView.borderWidth = 2
        userNameLabel.text = userInfo.name
        postNumberLabel.text = "\(userInfo.postNumber) 則想法"
        followerNumberLabel.text = "\(userInfo.followerNumber) 被追蹤"
        followingNumberLabel.text = "\(userInfo.followingNumber) 追蹤中"
    }

    func setupProfileImage() {

        profileImageView.cornerRadius = profileImageView.frame.width / 2
        profileImageView.contentMode = .scaleAspectFill
        shadowView.cornerRadius = shadowView.frame.width / 2
        shadowView.dropShadow(isPath: false)
        editImageButton.cornerRadius = editImageButton.frame.width / 2
        editImageButton.borderWidth = 1
        editImageButton.borderColor = . white
        editImageButton.setTitle("", for: .normal)
        editNameButton.setTitle("", for: .normal)
    }

    func setupButtons() {

        blockButton.cornerRadius = CornerRadius.standard.rawValue * 2 / 3
        followButton.cornerRadius = CornerRadius.standard.rawValue * 2 / 3
        blockButton.backgroundColor = .white
        followButton.backgroundColor = .white
    }
}
