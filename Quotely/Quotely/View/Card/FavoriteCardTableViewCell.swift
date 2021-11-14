//
//  FavoriteCardTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/28.
//

import Foundation
import UIKit

class FavoriteCardTableViewCell: UITableViewCell {

    @IBOutlet weak var cardContentLabel: UILabel!
    @IBOutlet weak var cardAuthorLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    let images = [
        UIImage.asset(.bg1),
        UIImage.asset(.bg2),
        UIImage.asset(.bg3),
        UIImage.asset(.bg4)
    ]

    override func awakeFromNib() {
        super.awakeFromNib()

        cardImageView.setSpecificCorner(corners: [.topRight, .bottomRight])
        cardImageView.clipsToBounds = true
        cardImageView.image = images[Int.random(in: 0...3)]
        backgroundColor = .clear
    }

    func layoutCell(
        content: String,
        author: String
    ) {

        cardContentLabel.text = content
        cardAuthorLabel.text = author
    }
}
