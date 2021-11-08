//
//  SwipeViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/23.
//

import Foundation
import UIKit

class SwipeViewController: UIViewController {

    let visitorUid = SignInManager.shared.uid ?? ""
    let notificationCenter = NotificationCenter.default
    let loadingAnimationView = LottieAnimationView(animationName: "loading")

    var cards = [Card]() {
        didSet {
            if cards.count >= 1 { likeNumberLabel.text = "\(cards[currentCardIndex].likeNumber)" }
        }
    }

    let educationDimmingView = UIView()
    var cardStack = SwipeCardStackView()
    let shareButton = ImageButton(image: UIImage.sfsymbol(.shareNormal)!, color: .white)
    let likeButton = ImageButton(image: UIImage.sfsymbol(.heartNormal)!, color: .white, hasLabel: true)
    let commentButton = ImageButton(image: UIImage.sfsymbol(.comment)!, color: .white, hasLabel: true)
    let resetButton = ImageButton(image: UIImage.sfsymbol(.reset)!, color: .M1!)
    let resetBackgroundView = UIView()
    let likeNumberLabel = ImageButtonLabel(color: .M1!)
    let commentNumberLabel = ImageButtonLabel(color: .M1!)

    var resetBackgroundViewHeight = NSLayoutConstraint()
    var resetBackgroundViewHeightHidden = NSLayoutConstraint()
    var resetBackgroundViewWidth = NSLayoutConstraint()
    var resetBackgroundViewWidthHidden = NSLayoutConstraint()

    var isLastCardSwiped = false {
        didSet {
            expandAnimation()
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
            text: nil,
            target: self,
            action: #selector(goToFavoritePage(_:)),
            color: .M1!
        )

        initialLoadingCards()
        setupCardView()
        setupButton()
        setupResetButton()

        if UIApplication.isFirstLaunch() { setEducationAnimation() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        resetBackgroundView.cornerRadius = resetBackgroundView.frame.width / 2
        resetButton.cornerRadius = resetButton.frame.width / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // open share template when a user takes screenshot

        notificationCenter.addObserver(
            self,
            selector: #selector(goToSharePage(_:)),
            name: UIApplication.userDidTakeScreenshotNotification, object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        notificationCenter.removeObserver(self)
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
                    self.cardStack.dataSource = self
                    self.cardStack.delegate = self

                case .failure(let error):

                    print(error)
                }

                group.leave()
            }

            group.notify(queue: DispatchQueue.main, execute: {

                self.loadingAnimationView.removeFromSuperview()

                self.likeNumberLabel.text = "\(self.cards[0].likeNumber)"
                self.commentNumberLabel.text = "\(self.cards[0].commentNumber)"

                self.shareButton.isEnabled = true
                self.likeButton.isEnabled = true
                self.commentButton.isEnabled = true
            })
        }
    }

    func updateCard(cardID: String, likeAction: LikeAction) {

        CardManager.shared.updateCards(cardID: cardID, likeAction: likeAction, uid: visitorUid) { result in

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
            uid: visitorUid,
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

        detailVC.card = card
        detailVC.isLike = card.likeUser.contains(visitorUid)

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

        shareVC.templateContent = [
            card.content.replacingOccurrences(of: "\\n", with: "\n"),
            card.author
        ]

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

        view.addSubview(loadingAnimationView)
        view.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingAnimationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            loadingAnimationView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            cardStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            cardStack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -20),
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
            $0.backgroundColor = .M2
            $0.cornerRadius = CornerRadius.standard.rawValue
        }

        commentButton.addTarget(self, action: #selector(goToDetailPage(_:)), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(tapLikeButton(_:)), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(goToSharePage(_:)), for: .touchUpInside)

        view.addSubview(likeNumberLabel)
        view.addSubview(commentNumberLabel)
        likeNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        commentNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            likeButton.bottomAnchor.constraint(equalTo: likeNumberLabel.topAnchor, constant: -12),
            likeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            likeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            likeButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),

            shareButton.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor),
            shareButton.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -16),
            shareButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            shareButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),

            commentButton.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor),
            commentButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 16),
            commentButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            commentButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),

            likeNumberLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor),
            likeNumberLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            commentNumberLabel.centerXAnchor.constraint(equalTo: commentButton.centerXAnchor),
            commentNumberLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    func setupResetButton() {

        view.addSubview(resetBackgroundView)
        view.addSubview(resetButton)

        resetButton.isHidden = !isLastCardSwiped

        resetBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        resetBackgroundView.backgroundColor = .M2
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(resetCards(_:)), for: .touchUpInside)
        resetButton.backgroundColor = .white

        resetBackgroundViewWidthHidden = resetBackgroundView.widthAnchor.constraint(equalToConstant: 0)
        resetBackgroundViewHeightHidden = resetBackgroundView.heightAnchor.constraint(equalToConstant: 0)
        resetBackgroundViewWidthHidden.isActive = !isLastCardSwiped
        resetBackgroundViewHeightHidden.isActive = !isLastCardSwiped

        resetBackgroundViewWidth = resetBackgroundView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2)
        resetBackgroundViewHeight = resetBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2)
        resetBackgroundViewWidth.isActive = isLastCardSwiped
        resetBackgroundViewHeight.isActive = isLastCardSwiped

//        resetBackgroundView.frame = CGRect(x: view.frame.width / 2, y: view.frame.height / 2, width: 0, height: 0)

        NSLayoutConstraint.activate([
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            resetButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            resetButton.heightAnchor.constraint(equalTo: resetButton.widthAnchor),

            resetBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func resetCards(_ sender: UIButton) {

        cards.removeAll()
        isLastCardSwiped = false
        initialLoadingCards()
        cardStack.nextCardIndex = 0
    }

    @objc func tapLikeButton(_ sender: UIButton) {

        guard let cardID = cards[currentCardIndex].cardID else {
            return Toast.showFailure(text: "收藏失敗")
        }

        updateUserLikeCardList(cardID: cardID, likeAction: .like)
        updateCard(cardID: cardID, likeAction: .like)
        cards[currentCardIndex].likeNumber += 1

        Toast.showSuccess(text: "已收藏")
    }

    func setEducationAnimation() {

        let titleLabel = UILabel()
        let swipeAnimationView = LottieAnimationView(animationName: "swipe")
        let okButton = UIButton()

        view.addSubview(educationDimmingView)
        view.bringSubviewToFront(educationDimmingView)
        educationDimmingView.translatesAutoresizingMaskIntoConstraints = false
        educationDimmingView.addSubview(swipeAnimationView)
        educationDimmingView.addSubview(titleLabel)
        educationDimmingView.addSubview(okButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeAnimationView.translatesAutoresizingMaskIntoConstraints = false
        okButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "試試看左右滑動卡片"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        okButton.setTitle("好喔", for: .normal)
        okButton.setTitleColor(.black, for: .normal)
        okButton.backgroundColor = .white.withAlphaComponent(0.8)
        okButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        okButton.cornerRadius = CornerRadius.standard.rawValue
        okButton.addTarget(self, action: #selector(dismissEducationAnimation(_:)), for: .touchUpInside)

        educationDimmingView.backgroundColor = .black.withAlphaComponent(0.75)

        NSLayoutConstraint.activate([
            educationDimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            educationDimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            educationDimmingView.widthAnchor.constraint(equalTo: view.widthAnchor),
            educationDimmingView.heightAnchor.constraint(equalTo: view.heightAnchor),

            swipeAnimationView.centerXAnchor.constraint(equalTo: educationDimmingView.centerXAnchor),
            swipeAnimationView.centerYAnchor.constraint(equalTo: educationDimmingView.centerYAnchor),
            swipeAnimationView.heightAnchor.constraint(equalTo: educationDimmingView.heightAnchor, multiplier: 0.5),
            swipeAnimationView.widthAnchor.constraint(equalTo: educationDimmingView.widthAnchor, multiplier: 0.5),

            titleLabel.bottomAnchor.constraint(equalTo: swipeAnimationView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: educationDimmingView.centerXAnchor),

            okButton.topAnchor.constraint(equalTo: swipeAnimationView.bottomAnchor, constant: -30),
            okButton.centerXAnchor.constraint(equalTo: educationDimmingView.centerXAnchor),
            okButton.widthAnchor.constraint(equalTo: educationDimmingView.widthAnchor, multiplier: 0.3),
            okButton.heightAnchor.constraint(equalTo: educationDimmingView.heightAnchor, multiplier: 0.05)
        ])
    }

    @objc func dismissEducationAnimation(_ sender: UIButton) { educationDimmingView.removeFromSuperview() }
}

extension SwipeViewController: SwipeCardStackViewDataSource, SwipeCardStackViewDelegate {

    func numbersOfCardsIn(_ stack: SwipeCardStackView) -> Int { cards.count }

    func authorForCardsIn(_ stack: SwipeCardStackView, index: Int) -> String { cards.reversed()[index].author }

    func cardForStackIn(_ card: SwipeCardStackView, index: Int) -> String { cards.reversed()[index].content }

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

    func expandAnimation() {

        if isLastCardSwiped == true {

            UIView.animate(withDuration: 1.5) {

                self.resetBackgroundViewWidthHidden.isActive = !self.isLastCardSwiped
                self.resetBackgroundViewHeightHidden.isActive = !self.isLastCardSwiped
                self.resetBackgroundViewWidth.isActive = self.isLastCardSwiped
                self.resetBackgroundViewHeight.isActive = self.isLastCardSwiped

                self.view.layoutIfNeeded()
            }

        } else {

            UIView.animate(withDuration: 1.5) {

                self.resetBackgroundViewWidth.isActive = self.isLastCardSwiped
                self.resetBackgroundViewHeight.isActive = self.isLastCardSwiped

                self.view.layoutIfNeeded()
            }
        }
    }
}
