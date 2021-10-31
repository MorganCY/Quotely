//
//  UINavigationItem+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/31.
//

import Foundation
import UIKit

extension UINavigationItem {

    func setupRightBarButton(image: UIImage, target: UIViewController, action: Selector?, color: UIColor) {

        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .default)

        let addPostImage = image.withConfiguration(config)

        rightBarButtonItem = UIBarButtonItem(
            image: addPostImage,
            style: .plain,
            target: target,
            action: action
        )

        rightBarButtonItem?.tintColor = color
    }
}

extension UINavigationController {

    func setupBackButton(color: UIColor) {

        let backbutton = UIBarButtonItem()
        backbutton.title = ""
        backbutton.tintColor = color

        navigationBar.topItem?.backBarButtonItem = backbutton
    }
}
