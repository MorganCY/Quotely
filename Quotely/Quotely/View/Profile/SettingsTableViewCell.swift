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

    var buttonHandler: () -> Void = {}

    @objc func tapButton(_ sender: UIButton) { buttonHandler() }

    func layoutCell(
        buttonTitle: String
    ) {

        optionButton.setTitle(buttonTitle, for: .normal)

        optionButton.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
    }
}
