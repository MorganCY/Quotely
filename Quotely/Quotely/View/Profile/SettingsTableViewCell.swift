//
//  SettingsTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/6.
//

import Foundation
import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var optionButton: UIButton!

    override func awakeFromNib() {

        backgroundColor = .clear
        optionButton.cornerRadius = CornerRadius.standard.rawValue
    }

    var signOutHandler: () -> Void = {}

    @objc func signOut(_ sender: UIButton) { signOutHandler() }

    func layoutCell(
        buttonTitle: String,
        isSignOutButton: Bool
    ) {

        optionButton.setTitle(buttonTitle, for: .normal)

        if isSignOutButton {

            optionButton.addTarget(self, action: #selector(signOut(_:)), for: .touchUpInside)

        } else {

            optionButton.backgroundColor = .clear
            optionButton.setTitleColor(.white, for: .normal)
        }
    }
}
