//
//  UITextView+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/26.
//

import Foundation
import UIKit
import UITextView_Placeholder

enum Placeholder: String {

    case comment = "有什麼感觸..."
}

extension UITextView {

    func placeholder(text: String, color: UIColor) {

        placeholder = text
        placeholderColor = color
    }
}
