//
//  UIApplication+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/7.
//

import Foundation
import UIKit

extension UIApplication {
    static func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "HasLaunched") {
            UserDefaults.standard.set(true, forKey: "HasLaunched")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
}
