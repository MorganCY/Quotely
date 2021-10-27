//
//  JournalListTableViewCell.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/27.
//

import Foundation
import UIKit

class JournalListTableViewCell: UITableViewCell {

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var journalCellView: UIView!
    @IBOutlet weak var emojiImageView: UIImageView!
    @IBOutlet weak var journalContent: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {

        dateView.cornerRadius = CornerRadius.standard.rawValue
        journalCellView.setSpecificCorner(corners: [.topLeft, .bottomLeft])
        backgroundColor = .clear
        emojiImageView.tintColor = .black
        journalContent.textColor = .gray
        timeLabel.textColor = .gray
    }

    func layoutCell(
        date: String,
        month: String,
        emoji: UIImage,
        content: String,
        time: String
    ) {

        dateLabel.text = date
        monthLabel.text = {
            switch month {

            case "1": return "JAN"
            case "2": return "FEB"
            case "3": return "MAR"
            case "4": return "APR"
            case "5": return "MAY"
            case "6": return "JUN"
            case "7": return "JUL"
            case "8": return "AUG"
            case "9": return "SEP"
            case "10": return "OCT"
            case "11": return "NOV"
            case "12": return "DEC"
            default: return ""
            }
        }()
        emojiImageView.image = emoji
        journalContent.text = content
        timeLabel.text = time
    }
}
