//
//  UIStoryboard+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

private struct StoryboardCategory {

    static let journal = "Journal"

    static let main = "Main"

    static let swipe = "Swipe"

    static let explore = "Explore"

    static let write = "Write"

    static let myAccount = "MyAccount"
}

extension UIStoryboard {

    static var main: UIStoryboard { return getStoryboard(name: StoryboardCategory.main) }

    static var journal: UIStoryboard { return getStoryboard(name: StoryboardCategory.journal) }

    static var swipe: UIStoryboard { return getStoryboard(name: StoryboardCategory.swipe) }

    static var explore: UIStoryboard { return getStoryboard(name: StoryboardCategory.explore) }

    static var write: UIStoryboard { return getStoryboard(name: StoryboardCategory.write) }

    static var myAccount: UIStoryboard { return getStoryboard(name: StoryboardCategory.myAccount) }

    private static func getStoryboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}
