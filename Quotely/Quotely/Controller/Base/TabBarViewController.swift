//
//  BaseTabBarViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

private enum Tab {

    case journal

    case swipe

    case explore

    case myAccount

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .journal: controller = UIStoryboard.journal.instantiateInitialViewController()!

        case .swipe: controller = UIStoryboard.swipe.instantiateInitialViewController()!

        case .explore: controller = UIStoryboard.explore.instantiateInitialViewController()!
        case .myAccount: controller = UIStoryboard.myAccount.instantiateInitialViewController()!

        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 16.0, left: 0.0, bottom: -6.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .journal:
            return UITabBarItem(
                title: nil,
                image: UIImage.sfsymbol(.write),
                selectedImage: UIImage.sfsymbol(.write)
            )

        case .swipe:
            return UITabBarItem(
                title: nil,
                image: UIImage.sfsymbol(.cardsNormal),
                selectedImage: UIImage.sfsymbol(.cardsSelected)
            )

        case .explore:
            return UITabBarItem(
                title: nil,
                image: UIImage.sfsymbol(.lightbulbNormal),
                selectedImage: UIImage.sfsymbol(.lightbulbSelected)
            )

        case .myAccount:
            return UITabBarItem(
                title: nil,
                image: UIImage.sfsymbol(.personNormal),
                selectedImage: UIImage.sfsymbol(.personSelected)
            )
        }
    }
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [.journal, .swipe, .explore, .myAccount]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.controller() })

        delegate = self
    }
}
