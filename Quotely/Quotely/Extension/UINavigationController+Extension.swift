//
//  UINavigationController+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/22.
//

import UIKit

extension UINavigationController {
    var previousViewController: UIViewController? {
        viewControllers.last {
            $0 != topViewController
        }
    }
}
