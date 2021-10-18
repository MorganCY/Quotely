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

    case write

    case map

    case myAccount

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .browse: controller = UIStoryboard.browse.instantiateInitialViewController()!

        case .explore: controller = UIStoryboard.explore.instantiateInitialViewController()!

        case .write: controller = UIStoryboard.write.instantiateInitialViewController()!

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

        case .write:
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

class BaseTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [.browse, .explore, .write, .map, .myAccount]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.controller() })

        delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let navVC = viewController as? UINavigationController,
              navVC.viewControllers.first is WriteViewController
        else { return true }

        if let writeVC = UIStoryboard.write.instantiateInitialViewController() {

            writeVC.modalPresentationStyle = .popover

            self.present(writeVC, animated: true, completion: nil)

            return false
        }

        return true
    }
}
