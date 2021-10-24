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

    func cardForStackIn(_ card: SwipeCardStackView, index: Int) -> String
}

protocol SwipeCardStackViewDelegate: AnyObject {

    func cardGoesLeft(_ stack: SwipeCardStackView, currentIndex: Int ,nextIndex: Int)

    func cardGoesRight(_ stack: SwipeCardStackView, currentIndex: Int ,nextIndex: Int)

    func getCurrentCard(_ card: SwipeCardStackView, index: Int)
}

class SwipeCardStackView: UIStackView {

    weak var dataSource: SwipeCardStackViewDataSource? {

        didSet {

            setupCards()
        }
    }

    weak var delegate: SwipeCardStackViewDelegate?

    let backgroundImages: [ImageAsset] = [.bg1, .bg2, .bg3]

    var nextCardIndex = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupCards() {

        guard let dataSource = dataSource else { return }

        for index in 0..<(dataSource.numbersOfCardsIn(self)) {

            let swipeCard = SwipeCardView()

            swipeCard.delegate = self

            swipeCard.contentLabel.text = dataSource.cardForStackIn(
                self,
                index: index)
                .replacingOccurrences(of: "\\n", with: "\n")

            swipeCard.backgroundImageView.image = UIImage.asset(backgroundImages[Int.random(in: 0...2)])

            addSubview(swipeCard)

            swipeCard.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([

                swipeCard.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                swipeCard.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(-15 * index)),
                swipeCard.widthAnchor.constraint(equalTo: self.widthAnchor),
                swipeCard.heightAnchor.constraint(equalTo: self.heightAnchor)
            ])
        }
    }

    func calculateIndex() {

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

    func getCurrentCard(_ card: SwipeCardView) {

        self.delegate?.getCurrentCard(self, index: nextCardIndex)
    }
}
