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

    var shareHandler: () -> Void = {}
    var likeHandler: () -> Void = {}
    var writeHandler: () -> Void = {}

    @IBAction func tapShareButton(_ sender: UIButton) {
        shareHandler()
    }

    @IBAction func tapLikeButton(_ sender: UIButton) {
        likeHandler()
    }

    @IBAction func tapWriteButton(_ sender: UIButton) {
        writeHandler()
    }

    func layoutHeader(card: Card) {
        cardContentLabel.text = card.content.replacingOccurrences(of: "\\n", with: "\n")
        cardAuthorLabel.text = card.author
    }
}
