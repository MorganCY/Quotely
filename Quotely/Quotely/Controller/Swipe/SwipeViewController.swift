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

    var cardStack = SwipeCardStackView()
    let shareButton = ImageButton(image: UIImage.sfsymbol(.shareNormal)!, color: .gray)
    let likeButton = ImageButton(image: UIImage.sfsymbol(.heartNormal)!, color: .gray, hasLabel: true)
    let commentButton = ImageButton(image: UIImage.sfsymbol(.comment)!, color: .gray, hasLabel: true)
    let resetButton = ImageButton(image: UIImage.sfsymbol(.reset)!, color: .gray)
    let likeNumberLabel = ImageButtonLabel(color: .gray)
    let commentNumberLabel = ImageButtonLabel(color: .gray)

    var isLastCardSwiped = false {
        didSet {
            resetButton.isHidden = !isLastCardSwiped
            commentButton.isEnabled = !isLastCardSwiped
        }
    }
    var currentCardIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "靈感"

        navigationItem.setupRightBarButton(
            image: UIImage.sfsymbol(.cards)!,
            target: self,
            action: #selector(goToFavoritePage(_:)),
            color: .M1!
        )

        initialLoadingCards()
        setupCardView()
        setupButton()
        setupReminder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func fetchCards() {

        CardManager.shared.fetchRandomCards(limitNumber: 6) { result in

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

            CardManager.shared.fetchRandomCards(limitNumber: 6) { result in
                switch result {

                case .success(let cards):

                    self.cards = cards

                case .failure(let error):

                    print(error)
                }

                group.leave()
            }

            group.notify(queue: DispatchQueue.main, execute: {

                self.loadingLabel.isHidden = true

                self.likeNumberLabel.text = "\(self.cards[0].likeNumber)"
                self.commentNumberLabel.text = "\(self.cards[0].commentNumber)"

                self.shareButton.isEnabled = true
                self.likeButton.isEnabled = true
                self.commentButton.isEnabled = true
            })
        }
    }

    func updateCard(cardID: String, likeAction: LikeAction) {

        CardManager.shared.updateCards(cardID: cardID, likeAction: likeAction, uid: "test123456") { result in

            switch result {

            case .success(let success):
                print(success)

            case .failure(let error):
                print(error)
            }
        }
    }

    func updateUserLikeCardList(cardID: String, likeAction: LikeAction) {

        UserManager.shared.updateFavoriteCard(
            uid: "test123456",
            cardID: cardID,
            likeAction: likeAction) { result in

                switch result {

                case .success(let success):
                    print(success)

                case .failure(let error):
                    print(error)
                }
            }
    }

    @objc func goToDetailPage(_ sender: UIButton) {

        guard let detailVC =
                UIStoryboard.swipe
                .instantiateViewController(
                    withIdentifier: String(describing: CardDetailViewController.self)
                ) as? CardDetailViewController else {

                    return
                }

        let card = cards[currentCardIndex]

        detailVC.cardID = card.cardID
        detailVC.hasLiked = card.likeUser.contains("test123456") ? true : false
        detailVC.uid = "test123456"
        detailVC.content = "\(card.content)\n\n\n\(card.author)"

        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc func goToSharePage(_ sender: UIButton) {

        guard let shareVC =
                UIStoryboard.share
                .instantiateViewController(
                    withIdentifier: String(describing: ShareViewController.self)
                ) as? ShareViewController else {

            return
        }

        let card = cards[currentCardIndex]
        let nav = BaseNavigationController(rootViewController: shareVC)

        shareVC.content = card.content
        shareVC.author = card.author

        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
    }

    @objc func goToFavoritePage(_ sender: UIBarButtonItem) {

        guard let favCardVC =
                UIStoryboard.swipe
                .instantiateViewController(
                    withIdentifier: String(describing: FavoriteCardViewController.self)
                ) as? FavoriteCardViewController else {

                    return
                }

        show(favCardVC, sender: nil)
    }

    func setupCardView() {

        view.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            cardStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
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
            $0.isEnabled = false
        }

        commentButton.addTarget(self, action: #selector(goToDetailPage(_:)), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(goToSharePage(_:)), for: .touchUpInside)

        view.addSubview(likeNumberLabel)
        view.addSubview(commentNumberLabel)
        likeNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        commentNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: cardStack.bottomAnchor, constant: 20),
            shareButton.leadingAnchor.constraint(equalTo: cardStack.leadingAnchor),
            shareButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12),
            shareButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12),

            likeButton.topAnchor.constraint(equalTo: shareButton.topAnchor),
            likeButton.centerXAnchor.constraint(equalTo: cardStack.centerXAnchor),
            likeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12),
            likeButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12),

            commentButton.topAnchor.constraint(equalTo: shareButton.topAnchor),
            commentButton.trailingAnchor.constraint(equalTo: cardStack.trailingAnchor),
            commentButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12),
            commentButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12),

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

        isLastCardSwiped = false

        NSLayoutConstraint.activate([
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            resetButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            resetButton.heightAnchor.constraint(equalTo: resetButton.widthAnchor)
        ])
    }

    @objc func resetCards(_ sender: UIButton) {

        cards.removeAll()
        isLastCardSwiped = false
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

        guard let cardID = cards[currentIndex].cardID else { return }

        updateUserLikeCardList(cardID: cardID, likeAction: .dislike)

        updateCard(cardID: cardID, likeAction: .dislike)

        if nextIndex < cards.count {

            likeNumberLabel.text = "\(cards[nextIndex].likeNumber)"
            commentNumberLabel.text = "\(cards[nextIndex].commentNumber)"
            currentCardIndex = nextIndex

        } else if nextIndex == cards.count {

            likeNumberLabel.text = ""
            commentNumberLabel.text = ""
            currentCardIndex = 0
            isLastCardSwiped = true
        }
    }

    func cardGoesRight(_ stack: SwipeCardStackView, currentIndex: Int, nextIndex: Int) {

        guard let cardID = cards[currentIndex].cardID else { return }

        updateUserLikeCardList(cardID: cardID, likeAction: .like)

        updateCard(cardID: cardID, likeAction: .like)

        if nextIndex < cards.count {

            likeNumberLabel.text = "\(cards[nextIndex].likeNumber)"
            commentNumberLabel.text = "\(cards[nextIndex].commentNumber)"
            currentCardIndex = nextIndex

        } else if nextIndex == cards.count {

            likeNumberLabel.text = ""
            commentNumberLabel.text = ""
            currentCardIndex = 0
            isLastCardSwiped = true
        }
    }
}
