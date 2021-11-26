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

    func cardForStackIn(_ stack: SwipeCardStackView, index: Int) -> String

    func authorForCardsIn(_ stack: SwipeCardStackView, index: Int) -> String
}

protocol SwipeCardStackViewDelegate: AnyObject {

    func cardGoesLeft(_ stack: SwipeCardStackView, currentIndex: Int, nextIndex: Int)

    func cardGoesRight(_ stack: SwipeCardStackView, currentIndex: Int, nextIndex: Int)
}

class SwipeCardStackView: UIStackView {

    weak var dataSource: SwipeCardStackViewDataSource? {

        didSet {
            setupCards()
        }
    }

    weak var delegate: SwipeCardStackViewDelegate?

    var nextCardIndex = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupCards() {

        guard let dataSource = dataSource else { return }

        for index in 0..<(dataSource.numbersOfCardsIn(self)) {

            let swipeCard = SwipeCardView()

            swipeCard.delegate = self
            swipeCard.dropShadow()

            swipeCard.contentLabel.text = dataSource.cardForStackIn(
                self,
                index: index)
                .replacingOccurrences(of: "\\n", with: "\n")

            swipeCard.authorLabel.text = dataSource.authorForCardsIn(self, index: index)

            addSubview(swipeCard)

            swipeCard.translatesAutoresizingMaskIntoConstraints = false

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

extension SwipeCardStackView: SwipeCardViewDelegate {

    func cardGoesRight(_ card: SwipeCardView) {

        calculateIndex()

        self.delegate?.cardGoesRight(self, currentIndex: nextCardIndex - 1, nextIndex: nextCardIndex)
    }

    func cardGoesLeft(_ card: SwipeCardView) {

        calculateIndex()

        self.delegate?.cardGoesLeft(self, currentIndex: nextCardIndex - 1, nextIndex: nextCardIndex)
    }
}
