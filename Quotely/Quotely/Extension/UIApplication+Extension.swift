//
//  UIApplication+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/7.
//

import Foundation
import UIKit

extension UIApplication {
    static func isFirstLaunch(forKey: String) -> Bool {
        if !UserDefaults.standard.bool(forKey: forKey) {
            UserDefaults.standard.set(true, forKey: forKey)
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
}
