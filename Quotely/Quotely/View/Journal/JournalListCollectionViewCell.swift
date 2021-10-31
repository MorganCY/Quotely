//
//  JournalListCollectionViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/27.
//

import Foundation
import UIKit

class JournalListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var background: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        background.cornerRadius = CornerRadius.standard.rawValue
        background.borderColor = .white
        background.borderWidth = 1
    }

    func layoutItem(month: String) {

        monthLabel.text = "\(month)月"

        setSelectedStyle()
    }

    func setDefaultStyle() {

        background.backgroundColor = .white
        monthLabel.textColor = .M2
    }

    func setSelectedStyle() {

        background.backgroundColor = isSelected
        ? .white : .M2
        monthLabel.textColor = isSelected
        ? .M1 : .white
    }
}
