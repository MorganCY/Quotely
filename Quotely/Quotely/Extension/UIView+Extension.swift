//
//  UIView+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

extension UIView {

    enum Side {

        case left, right, top, bottom
    }

    func addBorder(toSide side: Side, withColor color: CGColor, width: CGFloat) {

        let border = CALayer()

        border.backgroundColor = color

        switch side {

        case .left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: width, height: frame.height)

        case .right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: width, height: frame.height)

        case .top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: width)

        case .bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: width)
        }

        layer.addSublayer(border)
    }
}