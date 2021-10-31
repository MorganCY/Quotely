//
//  BaseNavigaitonController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/31.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setBackgroundImage(UIImage(), for: .default)

        navigationBar.shadowImage = UIImage()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
