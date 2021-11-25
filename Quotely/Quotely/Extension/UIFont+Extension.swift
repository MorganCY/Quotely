//
//  UIFont+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/25.
//

import UIKit

extension UIFont {

    private enum FontName: String {

        case regular = "PingfangTC-Regular"
        case bold = "PingfangTC-Semibold"
    }

    static func setRegular(size: CGFloat) -> UIFont? {

        return baseFont(.regular, size: size)
    }

    static func setBold(size: CGFloat) -> UIFont? {

        return baseFont(.bold, size: size)
    }

    private static func baseFont(_ font: FontName, size: CGFloat) -> UIFont? {

        return UIFont(name: font.rawValue, size: size)
    }
}
