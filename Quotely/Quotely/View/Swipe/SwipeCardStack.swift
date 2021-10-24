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

    func cardForStackIn(_ card: SwipeCardView, index: Int) -> String
}

protocol SwipeCardStackViewDelegate: AnyObject {

    func cardGoesLeft(_ stack: SwipeCardStackView)

    func cardGoesRight(_ stack: SwipeCardStackView)
}

class SwipeCardStackView: UIStackView {

    weak var dataSource: SwipeCardStackViewDataSource? {

        didSet {

            setupCards()
        }
    }

    weak var delegate: SwipeCardStackViewDelegate?

    let backgroundImages: [ImageAsset] = [.bg1, .bg2, .bg3]

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

            swipeCard.contentLabel.text = dataSource.cardForStackIn(
                swipeCard,
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
}

extension SwipeCardStackView: SwipeCardViewDelegate {

    func cardGoesRight(_ card: SwipeCardView) {

        self.delegate?.cardGoesRight(self)
    }

    func cardGoesLeft(_ card: SwipeCardView) {

        self.delegate?.cardGoesLeft(self)
    }
}
