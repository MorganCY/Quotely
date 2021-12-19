//
//  SwipeCardStack.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/24.
//

import Foundation
import UIKit

protocol SwipeCardStackViewDataSource: AnyObject {

    func numbersOfCardsIn(_ stack: SwipeCardContainerView) -> Int

    func cardForStackIn(_ stack: SwipeCardContainerView, index: Int) -> String

    func authorForCardsIn(_ stack: SwipeCardContainerView, index: Int) -> String
}

protocol SwipeCardStackViewDelegate: AnyObject {

    func cardGoesLeft(_ stack: SwipeCardContainerView, currentIndex: Int, nextIndex: Int)

    func cardGoesRight(_ stack: SwipeCardContainerView, currentIndex: Int, nextIndex: Int)
}

class SwipeCardContainerView: UIView {

    weak var dataSource: SwipeCardStackViewDataSource? {
        didSet {
            setupCards()
        }
    }

    weak var delegate: SwipeCardStackViewDelegate?

    var cardIndexForContent = 0

    var nextCardIndex = 0

    private func setupCards() {

        guard let dataSource = dataSource else { return }

        for index in 0..<(dataSource.numbersOfCardsIn(self)) {

            cardIndexForContent = index

            let swipeCard = SwipeCardView()
            swipeCard.delegate = self
            swipeCard.dataSource = self
            swipeCard.translatesAutoresizingMaskIntoConstraints = false
            addSubview(swipeCard)

            NSLayoutConstraint.activate([

                swipeCard.centerYAnchor.constraint(equalTo: centerYAnchor),
                swipeCard.centerXAnchor.constraint(equalTo: centerXAnchor),
                swipeCard.widthAnchor.constraint(equalTo: widthAnchor),
                swipeCard.heightAnchor.constraint(equalTo: heightAnchor)
            ])
        }
    }

    private func calculateIndex() {

        guard let dataSource = dataSource else { return }

        if nextCardIndex < dataSource.numbersOfCardsIn(self) {

            nextCardIndex += 1
        }
    }
}

extension SwipeCardContainerView: SwipeCardViewDelegate, SwipeCardViewDataSource {

    func cardGoesRight(_ card: SwipeCardView) {

        calculateIndex()

        self.delegate?.cardGoesRight(self, currentIndex: nextCardIndex - 1, nextIndex: nextCardIndex)
    }

    func cardGoesLeft(_ card: SwipeCardView) {

        calculateIndex()

        self.delegate?.cardGoesLeft(self, currentIndex: nextCardIndex - 1, nextIndex: nextCardIndex)
    }

    func contentForCard(_ card: SwipeCardView) -> String {
        guard let dataSource = dataSource else {
            return ""
        }

        return dataSource.cardForStackIn(
            self, index: cardIndexForContent).replacingOccurrences(of: "\\n", with: "\n")
    }

    func authorForCard(_ card: SwipeCardView) -> String {
        guard let dataSource = dataSource else {
            return ""
        }

        return dataSource.authorForCardsIn(self, index: cardIndexForContent)
    }
}
