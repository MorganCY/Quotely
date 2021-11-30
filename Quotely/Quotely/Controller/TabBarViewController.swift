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

        guard let journalStoryboard = UIStoryboard.journal.instantiateInitialViewController(),
              let cardStoryboard = UIStoryboard.card.instantiateInitialViewController(),
              let exploreStoryboard = UIStoryboard.explore.instantiateInitialViewController(),
              let profileStoryboard = UIStoryboard.profile.instantiateInitialViewController()
        else { return UIViewController() }

        switch self {

        case .journal: controller = journalStoryboard

        case .card: controller = cardStoryboard

        case .explore: controller = exploreStoryboard

        case .profile: controller = profileStoryboard
        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 12.0, left: 0.0, bottom: 12.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .journal:
            return UITabBarItem(
                title: "隻字",
                image: UIImage.sfsymbol(.writeNormal),
                selectedImage: UIImage.sfsymbol(.writeSelected)
            )

        case .card:
            return UITabBarItem(
                title: "片語",
                image: UIImage.sfsymbol(.lightbulbNormal),
                selectedImage: UIImage.sfsymbol(.lightbulbSelected)
            )

        case .explore:
            return UITabBarItem(
                title: "想法",
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
    }

    func setupTabbarStyle() {

        tabBar.tintColor = .M1

        tabBar.barTintColor = .white

        if #available(iOS 15, *) {

            let tabBarAppearance = UITabBarAppearance()

            tabBarAppearance.backgroundColor = .white

            tabBar.standardAppearance = tabBarAppearance

            tabBar.scrollEdgeAppearance = tabBarAppearance

        }
    }
}
