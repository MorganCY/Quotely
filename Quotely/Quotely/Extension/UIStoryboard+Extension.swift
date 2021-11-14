//
//  UIStoryboard+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

private struct StoryboardCategory {

    static let auth = "Auth"

    static let main = "Main"

    static let journal = "Journal"

    static let card = "Card"

    static let explore = "Explore"

    static let write = "Write"

    static let profile = "Profile"

    static let share = "Share"
}

extension UIStoryboard {

    static var auth: UIStoryboard { return getStoryboard(name: StoryboardCategory.auth) }

    static var main: UIStoryboard { return getStoryboard(name: StoryboardCategory.main) }

    static var journal: UIStoryboard { return getStoryboard(name: StoryboardCategory.journal) }

    static var card: UIStoryboard { return getStoryboard(name: StoryboardCategory.card) }

    static var explore: UIStoryboard { return getStoryboard(name: StoryboardCategory.explore) }

    static var write: UIStoryboard { return getStoryboard(name: StoryboardCategory.write) }

    static var profile: UIStoryboard { return getStoryboard(name: StoryboardCategory.profile) }

    static var share: UIStoryboard { return getStoryboard(name: StoryboardCategory.share) }

    private static func getStoryboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}
