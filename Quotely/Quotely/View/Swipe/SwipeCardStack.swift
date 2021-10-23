//
//  SwipeCardStack.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/24.
//

import Foundation
import UIKit

protocol SwipeCardStackViewDataSource: AnyObject {

    func numbersOfCardsIn(_ stack: SwipeCardStackView) -> Int
}

protocol SwipeCardStackViewDelegate: AnyObject {

    func cardGoesLeft(_ stack: SwipeCardStackView)

    func cardGoesRight(_ stack: SwipeCardStackView)
}

class SwipeCardStackView: UIStackView {

    weak var dataSource: SwipeCardStackViewDataSource?

    weak var delegate: SwipeCardStackViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCards()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupCards() {

        for _ in 0...(dataSource?.numbersOfCardsIn(self) ?? 1) {

            let swipeCard = SwipeCardView()

            addSubview(swipeCard)

            swipeCard.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([

                swipeCard.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                swipeCard.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                swipeCard.widthAnchor.constraint(equalTo: self.widthAnchor),
                swipeCard.heightAnchor.constraint(equalTo: self.heightAnchor)
            ])
        }
    }
}

extension SwipeCardStackView: SwipeCardViewDelegate {

    func cardGoesRight(_ card: SwipeCardView) {

        self.delegate?.cardGoesRight(self)
    }

    func cardGoesLeft(_ card: SwipeCardView) {

        self.delegate?.cardGoesLeft(self)
    }
}
