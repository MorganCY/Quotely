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

    @IBOutlet weak var followStackView: UIStackView!
    @IBOutlet weak var postNumberLabel: UILabel!
    @IBOutlet weak var followerNumberLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var followButton: UIButton!

    var isEditing = false {
        didSet {

            userNameLabel.isHidden = isEditing
            editNameButton.isHidden = isEditing
            editNameTextField.isHidden = !isEditing
            doneEditNameButton.isHidden = !isEditing
        }
    }

    var isVisitorProfile = true {
        didSet {
            defineIfDisplay()
        }
    }

    override func awakeFromNib() {

        setupProfileImage()
        setupButtons()

        defineIfDisplay()
        userNameLabel.isHidden = isEditing
        editNameTextField.isHidden = !isEditing
        doneEditNameButton.isHidden = !isEditing
    }

    var editImageHandler: () -> Void = {}
    var editNameHandler: ((String) -> Void) = {_ in }
    var followHandler: (() -> Void) = {}
    var blockHanlder: (() -> Void) = {}

    @IBAction func editImage(_ sender: UIButton) {

        editImageHandler()
    }

    @IBAction func editName(_ sender: UIButton) {

        isEditing = true

        editNameTextField.text = userNameLabel.text
    }

    @IBAction func doneEditing(_ sender: UIButton) {

        guard let text = editNameTextField.text else { return }

        editNameHandler(text)
        userNameLabel.text = text
        isEditing = false
    }

    @IBAction func tapBlockButton(_ sender: UIButton) {

        blockHanlder()
    }

    @IBAction func tapFollowButton(_ sender: UIButton) {

        followHandler()
    }

    func defineIfDisplay() {

        editImageButton.isHidden = !isVisitorProfile
        editNameButton.isHidden = !isVisitorProfile
        blockButton.isHidden = isVisitorProfile
        followButton.isHidden = isVisitorProfile
    }

    func layoutHeader(
        userInfo: User,
        isBlock: Bool,
        isFollow: Bool
    ) {

        if let profileImageUrl = userInfo.profileImageUrl {

            profileImageView.loadImage(profileImageUrl, placeHolder: nil)

        } else {

            profileImageView.image = UIImage.asset(.logo)
        }

        if isBlock {

            blockButton.setTitle("解除封鎖", for: .normal)
            blockButton.setTitleColor(.lightGray, for: .normal)
            blockButton.backgroundColor = .gray
            blockButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        } else {

            blockButton.setTitle("封鎖他", for: .normal)
            blockButton.setTitleColor(.M1, for: .normal)
            blockButton.backgroundColor = .white
            blockButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        }

        if isFollow {

            followButton.setTitle("追蹤中", for: .normal)
            followButton.setTitleColor(.M2, for: .normal)
            followButton.backgroundColor = .M1
            followButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        } else {

            followButton.setTitle("追蹤他", for: .normal)
            followButton.setTitleColor(.M1, for: .normal)
            followButton.backgroundColor = .white
            followButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        }

        profileImageView.borderColor = .white
        profileImageView.borderWidth = 2
        profileImageView.cornerRadius = profileImageView.frame.width / 2
        editImageButton.cornerRadius = editImageButton.frame.width / 2
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
