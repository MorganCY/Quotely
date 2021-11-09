//
//  CardTopicTableViewHeader.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/9.
//

import Foundation
import UIKit

class CardTopicTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var cardContentLabel: UILabel!
    @IBOutlet weak var cardAuthorLabel: UILabel!

    func layoutHeader(card: Card) {
        cardContentLabel.text = card.content
        cardAuthorLabel.text = card.author
    }
}
