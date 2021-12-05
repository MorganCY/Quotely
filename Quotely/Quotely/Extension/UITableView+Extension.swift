//
//  UITableView+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

extension UITableView {

    func registerCellWithNib(identifier: String, bundle: Bundle?) {

        let nib = UINib(nibName: identifier, bundle: bundle)

        register(nib, forCellReuseIdentifier: identifier)
    }

    func registerHeaderWithNib(identifier: String, bundle: Bundle?) {

        let nib = UINib(nibName: identifier, bundle: bundle)

        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }

    func fadeInCells(cell: UITableViewCell, duration: CGFloat, delay: CGFloat, row: Int) {

        cell.alpha = 0

        UIView.animate(
            withDuration: duration,
            delay: delay * Double(row),
            animations: {
                cell.alpha = 1
        })
    }
}

extension UITableViewCell {

    static var identifier: String {

        return String(describing: self)
    }

    func hideSelectionStyle() {

        self.selectionStyle = .none
    }
}

extension UITableViewHeaderFooterView {

    static var identifier: String {

        return String(describing: self)
    }
}
