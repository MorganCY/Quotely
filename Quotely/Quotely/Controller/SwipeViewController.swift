//
//  SwipeViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/23.
//

import Foundation
import UIKit

class SwipeViewController: UIViewController {

    var cards = [Card]() {
        didSet {
            cardStack.dataSource = self
            cardStack.delegate = self
        }
    }

    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    var cardStack = SwipeCardStackView()
    let shareButton = IconButton(image: UIImage.sfsymbol(.shareNormal)!, color: .gray)
    let likeButton = IconButton(image: UIImage.sfsymbol(.heartNormal)!, color: .gray)
    let commentButton = IconButton(image: UIImage.sfsymbol(.comment)!, color: .gray)
    let resetButton = IconButton(image: UIImage.sfsymbol(.reset)!, color: .gray)
    let likeNumberLabel = IconButtonLabel()
    let commentNumberLabel = IconButtonLabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "瀏覽"

        initialLoadingCards()
        setupCardView()
        setupButton()
        setupReminder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func fetchCards() {

        CardManager.shared.fetchCards { result in

            switch result {

            case .success(let cards):

                self.cards = cards

            case .failure(let error):

                print(error)
            }
        }
    }

    func initialLoadingCards() {

        DispatchQueue.global().async {

            let group = DispatchGroup()

            group.enter()

            CardManager.shared.fetchCards { result in

                switch result {

                case .success(let cards):

                    self.cards = cards

                case .failure(let error):

                    print(error)
                }

                group.leave()
            }

            group.notify(queue: DispatchQueue.main) {

                self.loadingLabel.isHidden = true

                self.likeNumberLabel.text = "\(self.cards[0].likeNumber)"
                self.commentNumberLabel.text = "\(self.cards[0].commentNumber)"
            }
        }
    }

    func setupCardView() {

        view.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            cardStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            cardStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ])
    }

    func setupButton() {

        let buttons = [shareButton, likeButton, commentButton]
        buttons.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(likeNumberLabel)
        view.addSubview(commentNumberLabel)
        likeNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        commentNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: cardStack.bottomAnchor, constant: 20),
            shareButton.leadingAnchor.constraint(equalTo: cardStack.leadingAnchor),
            shareButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.08),
            shareButton.heightAnchor.constraint(equalTo: shareButton.widthAnchor),

            likeButton.topAnchor.constraint(equalTo: shareButton.topAnchor),
            likeButton.centerXAnchor.constraint(equalTo: cardStack.centerXAnchor),
            likeButton.widthAnchor.constraint(equalTo: shareButton.widthAnchor),
            likeButton.heightAnchor.constraint(equalTo: shareButton.widthAnchor),

            commentButton.topAnchor.constraint(equalTo: shareButton.topAnchor),
            commentButton.trailingAnchor.constraint(equalTo: cardStack.trailingAnchor),
            commentButton.widthAnchor.constraint(equalTo: shareButton.widthAnchor),
            commentButton.heightAnchor.constraint(equalTo: commentButton.widthAnchor),

            likeNumberLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor),
            likeNumberLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 6),
            commentNumberLabel.centerXAnchor.constraint(equalTo: commentButton.centerXAnchor),
            commentNumberLabel.topAnchor.constraint(equalTo: likeNumberLabel.topAnchor)
        ])
    }

    func setupReminder() {

        view.addSubview(resetButton)

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(resetCards(_:)), for: .touchUpInside)

        resetButton.isHidden = true
        reminderLabel.isHidden = true

        NSLayoutConstraint.activate([
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: reminderLabel.bottomAnchor, constant: 20),
            resetButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            resetButton.heightAnchor.constraint(equalTo: resetButton.widthAnchor)
        ])
    }

    @objc func resetCards(_ sender: UIButton) {

        cards.removeAll()
        reminderLabel.isHidden = true
        resetButton.isHidden = true
        initialLoadingCards()
        cardStack.nextCardIndex = 0
    }
}

extension SwipeViewController: SwipeCardStackViewDataSource, SwipeCardStackViewDelegate {

    func numbersOfCardsIn(_ stack: SwipeCardStackView) -> Int {

        return cards.count
    }

    func authorForCardsIn(_ stack: SwipeCardStackView, index: Int) -> String {

        return cards.reversed()[index].author
    }

    func cardForStackIn(_ card: SwipeCardStackView, index: Int) -> String {

        return cards.reversed()[index].content
    }

    func cardGoesLeft(_ stack: SwipeCardStackView, currentIndex: Int, nextIndex: Int) {

        if nextIndex < cards.count {

            likeNumberLabel.text = "\(cards[nextIndex].likeNumber)"
            commentNumberLabel.text = "\(cards[nextIndex].commentNumber)"

        } else if nextIndex == cards.count {

            likeNumberLabel.text = ""
            commentNumberLabel.text = ""
            reminderLabel.isHidden = false
            resetButton.isHidden = false
        }
    }

    func cardGoesRight(_ stack: SwipeCardStackView, currentIndex: Int, nextIndex: Int) {

        guard let cardID = cards[currentIndex].cardID else { return }

        CardManager.shared.updateCards(cardID: cardID, likeAction: .like, uid: "test123456") { result in

            switch result {

            case .success(let success):
                print(success)

            case .failure(let error):
                print(error)
            }
        }

        if nextIndex < cards.count {

            likeNumberLabel.text = "\(cards[nextIndex].likeNumber)"
            commentNumberLabel.text = "\(cards[nextIndex].commentNumber)"

        } else if nextIndex == cards.count {

            likeNumberLabel.text = ""
            commentNumberLabel.text = ""
            reminderLabel.isHidden = false
            resetButton.isHidden = false
        }
    }
}
