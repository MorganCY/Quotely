//
//  FavoriteCardTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/28.
//

import Foundation
import UIKit

class FavoriteCardTableViewCell: UITableViewCell {

    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardContent: UILabel!
    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var authorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        cardImageView.cornerRadius = CornerRadius.standard.rawValue
        cellBackground.cornerRadius = CornerRadius.standard.rawValue
        backgroundColor = .clear
        cardImageView.contentMode = .scaleAspectFill
        cardImageView.clipsToBounds = true
    }

    func layoutCell(
        content: String,
        author: String
    ) {

        cardContent.text = content
        authorLabel.text = author
    }
}
