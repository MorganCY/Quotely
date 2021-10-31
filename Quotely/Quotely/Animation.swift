//
//  Animation.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/27.
//

import Foundation
import UIKit

typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void

final class Animator {

    private var hasAnimatedAllCells = false
    private let animation: Animation

    init(animation: @escaping Animation) {

        self.animation = animation
    }

    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {

        guard !hasAnimatedAllCells else {
            return
        }

        animation(cell, indexPath, tableView)

        hasAnimatedAllCells = tableView.isLastVisibleCell(at: indexPath)
    }
}

enum AnimationFactory {

    static func takeTurnsFadingIn(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in

            cell.alpha = 0

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                animations: {
                    cell.alpha = 1
            })
        }
    }
}
