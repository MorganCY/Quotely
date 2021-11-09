//
//  BaseTabBarViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

private enum Tab {

    case journal

    case card

    case explore

    case profile

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .journal: controller = UIStoryboard.journal.instantiateInitialViewController()!

        case .card: controller = UIStoryboard.card.instantiateInitialViewController()!

        case .explore: controller = UIStoryboard.explore.instantiateInitialViewController()!

        case .profile: controller = UIStoryboard.profile.instantiateInitialViewController()!
        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 12.0, left: 0.0, bottom: 12.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .journal:
            return UITabBarItem(
                title: "隨筆",
                image: UIImage.sfsymbol(.write),
                selectedImage: UIImage.sfsymbol(.write)
            )

        case .card:
            return UITabBarItem(
                title: "靈感",
                image: UIImage.sfsymbol(.lightbulbNormal),
                selectedImage: UIImage.sfsymbol(.lightbulbSelected)
            )

        case .explore:
            return UITabBarItem(
                title: "探索",
                image: UIImage.sfsymbol(.quoteNormal),
                selectedImage: UIImage.sfsymbol(.quoteSelected)
            )

        case .profile:
            return UITabBarItem(
                title: "我的",
                image: UIImage.sfsymbol(.personNormal),
                selectedImage: UIImage.sfsymbol(.personSelected)
            )
        }
    }
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [.journal, .card, .explore, .profile]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.controller() })

        delegate = self

        setupTabbarStyle()

        tabBar.tintColor = .M1
    }

    func setupTabbarStyle() {

        if #available(iOS 15, *) {

            let tabBarAppearance = UITabBarAppearance()

            tabBarAppearance.backgroundColor = .white

            tabBar.standardAppearance = tabBarAppearance

            tabBar.scrollEdgeAppearance = tabBarAppearance

        } else {

            tabBar.barTintColor = .white
        }
    }
}
