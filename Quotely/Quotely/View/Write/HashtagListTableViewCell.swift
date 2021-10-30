//
//  HashtagTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/30.
//

import Foundation
import UIKit

class HashtagListTableViewCell: UITableViewCell {

    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var postNumber: UILabel!

    func layoutCell(
        hashtag: Hashtag
    ) {

        hashtagLabel.text = hashtag.title
        self.postNumber.text = "\(hashtag.postNumber ?? 0)" + "則想法"
    }
}
