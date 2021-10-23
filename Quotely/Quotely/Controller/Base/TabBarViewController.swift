//
//  BaseTabBarViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

private enum Tab {

    case browse

    case explore
    
    case map

    case myAccount

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .browse: controller = UIStoryboard.browse.instantiateInitialViewController()!

        case .explore: controller = UIStoryboard.explore.instantiateInitialViewController()!

        case .map: controller = UIStoryboard.map.instantiateInitialViewController()!

        case .myAccount: controller = UIStoryboard.myAccount.instantiateInitialViewController()!

        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .browse:
            return UITabBarItem(
                title: nil,
                image: UIImage.sfsymbol(.newspaperNormal),
                selectedImage: UIImage.sfsymbol(.newpaperSelected)
            )

        case .explore:
            return UITabBarItem(
                title: nil,
                image: UIImage.sfsymbol(.newspaperNormal),
                selectedImage: UIImage.sfsymbol(.newpaperSelected)
            )

        case .map:
            return UITabBarItem(
                title: nil,
                image: UIImage.sfsymbol(.newspaperNormal),
                selectedImage: UIImage.sfsymbol(.newpaperSelected)
            )

        case .myAccount:
            return UITabBarItem(
                title: nil,
                image: UIImage.sfsymbol(.newspaperNormal),
                selectedImage: UIImage.sfsymbol(.newpaperSelected)
            )
        }
    }
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [.browse, .explore, .map, .myAccount]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.controller() })

        delegate = self
    }
}
