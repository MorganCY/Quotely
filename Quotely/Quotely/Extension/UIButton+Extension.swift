//
//  UIButton+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/10.
//

import Foundation
import UIKit

extension UIButton {
    override open var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.alpha = 1.0
            } else {
                self.alpha = 0.3
            }
            self.layoutIfNeeded()
        }
    }
}
