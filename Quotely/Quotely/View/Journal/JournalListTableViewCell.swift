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

    var isDateDuplicate = false {
        didSet {
            dateView.isHidden = isDateDuplicate
            dateLabel.isHidden = isDateDuplicate
            monthLabel.isHidden = isDateDuplicate
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        dateView.cornerRadius = CornerRadius.standard.rawValue
        journalCellView.setSpecificCorner(corners: [.topLeft, .bottomLeft])
        backgroundColor = .clear
        emojiImageView.tintColor = .black
        journalContent.textColor = .gray
        timeLabel.textColor = .gray
    }

    func layoutCell(journal: Journal, month: String) {

        dateLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: journal.createdTime))
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
        emojiImageView.image = UIImage.sfsymbol(SFSymbol(rawValue: journal.emoji) ?? .smile) ?? UIImage()
        journalContent.text = journal.content
        timeLabel.text = Date.timeFormatter.string(from: Date.init(milliseconds: journal.createdTime))
    }

    func checkIfHideLabel(
        row: Journal,
        previousRow: Journal
    ) {

        isDateDuplicate = false

        if "\(Date.dateFormatter.string(from: Date.init(milliseconds: row.createdTime)))"
            ==
            "\(Date.dateFormatter.string(from: Date.init(milliseconds: previousRow.createdTime)))" {

            isDateDuplicate = true
        }

    }
}
