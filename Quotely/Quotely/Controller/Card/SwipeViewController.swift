//
//  SwipeViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/23.
//

import Foundation
import UIKit

class SwipeViewController: UIViewController {

    // MARK: Screenshot Notification
    private let notificationCenter = NotificationCenter.default

    // MARK: Card Data
    private var cards = [Card]() {
        didSet {
            if cards.count >= 1 {
                likeNumberLabel.text = "\(cards[currentCardIndex].likeNumber)"
                loadingAnimationView.removeFromSuperview()
            }
        }
    }

    // MARK: Interface
    private let loadingAnimationView = LottieAnimationView(animationName: "greenLoading")
    private let educationDimmingView = UIView()
    private var cardStack = SwipeCardStackView()
    private let shareButton = ImageButton(
        image: UIImage.sfsymbol(.shareNormal),
        color: .white,
        labelTitle: "分享",
        labelColor: .gray)
    private let likeButton = ImageButton(image: UIImage.sfsymbol(.bookmarkNormal), color: .white)
    private let writeButton = ImageButton(
        image: UIImage.sfsymbol(.writeCardPost),
        color: .white,
        labelTitle: "引用片語",
        labelColor: .gray)
    private let resetButton = ImageButton(image: UIImage.sfsymbol(.reset), color: .M1)
    private let resetBackgroundView = UIView()
    private let likeNumberLabel = ImageButtonLabel(color: .gray)

    private var resetBackgroundViewHeight = NSLayoutConstraint()
    private var resetBackgroundViewHeightHidden = NSLayoutConstraint()
    private var resetBackgroundViewWidth = NSLayoutConstraint()
    private var resetBackgroundViewWidthHidden = NSLayoutConstraint()

    private var isLastCardSwiped = false {
        didSet {
            setupExpandAnimation()
            resetButton.isHidden = !isLastCardSwiped
            shareButton.isEnabled = !isLastCardSwiped
            likeButton.isEnabled = !isLastCardSwiped
            writeButton.isEnabled = !isLastCardSwiped
        }
    }
    private var currentCardIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingAnimationView()
        initialLoadingCards()
        setupNavigation()
        setupCardView()
        setupButtons()
        setupResetButton()
        view.backgroundColor = .BG
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIApplication.isFirstLaunch(forKey: "HasLaunchedSwipeVC") {
            setupEducationView()
        }
        resetBackgroundView.cornerRadius = resetBackgroundView.frame.width / 2
        resetButton.cornerRadius = resetButton.frame.width / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(
            self, selector: #selector(tapShareButton(_:)),
            name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationCenter.removeObserver(self)
    }

    func initialLoadingCards() {

        CardManager.shared.fetchRandomCards(limitNumber: 6) { result in

            switch result {

            case .success(let cards):
                self.cards = cards
                self.cardStack.dataSource = self
                self.cardStack.delegate = self
                self.likeNumberLabel.text = "收藏數 \(self.cards[0].likeNumber)"
                self.shareButton.isEnabled = true
                self.likeButton.isEnabled = true
                self.writeButton.isEnabled = true

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToDownload.rawValue)
            }
        }
    }

    func fetchCards() {

        CardManager.shared.fetchRandomCards(limitNumber: 6) { result in

            switch result {

            case .success(let cards):
                self.cards = cards

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToDownload.rawValue)
            }
        }
    }

    func updateUserLikeCardList(
        visitorUid: String,
        cardID: String,
        likeAction: FirebaseAction
    ) {

        UserManager.shared.updateFavoriteCard(
            cardID: cardID,
            likeAction: likeAction
        ) { result in

            switch result {

            case .success(let success):
                print(success)

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToDownload.rawValue)
            }
        }
    }

    func updateCard(cardID: String, likeAction: FirebaseAction) {

        FirebaseManager.shared.updateFieldNumber(
            collection: .cards,
            targetID: cardID,
            action: likeAction,
            updateType: .like
        ) { result in

            switch result {

            case .success(let successStatus):
                print(successStatus)

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToDownload.rawValue)
            }
        }
    }
}

extension SwipeViewController: SwipeCardStackViewDataSource, SwipeCardStackViewDelegate {

    func numbersOfCardsIn(_ stack: SwipeCardStackView) -> Int { cards.count }

    func authorForCardsIn(_ stack: SwipeCardStackView, index: Int) -> String { cards.reversed()[index].author }

    func cardForStackIn(_ card: SwipeCardStackView, index: Int) -> String { cards.reversed()[index].content }

    func cardGoesLeft(_ stack: SwipeCardStackView, currentIndex: Int, nextIndex: Int) {

        guard let cardID = cards[currentIndex].cardID else { return }

        updateUserLikeCardList(visitorUid: SignInManager.shared.visitorUid ?? "", cardID: cardID, likeAction: .negative)

        updateCard(cardID: cardID, likeAction: .negative)

        if nextIndex < cards.count {

            likeNumberLabel.text = "收藏數 \(cards[nextIndex].likeNumber)"
            currentCardIndex = nextIndex

        } else if nextIndex == cards.count {

            likeNumberLabel.text = ""
            currentCardIndex = 0
            isLastCardSwiped = true
        }
    }

    func cardGoesRight(_ stack: SwipeCardStackView, currentIndex: Int, nextIndex: Int) {

        guard let cardID = cards[currentIndex].cardID else { return }

        updateUserLikeCardList(visitorUid: SignInManager.shared.visitorUid ?? "", cardID: cardID, likeAction: .positive)

        updateCard(cardID: cardID, likeAction: .positive)

        if nextIndex < cards.count {

            likeNumberLabel.text = "收藏數 \(cards[nextIndex].likeNumber)"
            currentCardIndex = nextIndex

        } else if nextIndex == cards.count {

            likeNumberLabel.text = ""
            currentCardIndex = 0
            isLastCardSwiped = true
        }
    }
}

extension SwipeViewController {

    @objc func tapShareButton(_ sender: UIButton) {

        guard let shareVC =
                UIStoryboard.share.instantiateViewController(
                    withIdentifier: ShareViewController.identifier
                ) as? ShareViewController
        else { return }

        let card = cards[currentCardIndex]
        let nav = BaseNavigationController(rootViewController: shareVC)

        shareVC.templateContent = [
            card.content.replacingOccurrences(of: "\\n", with: "\n"),
            card.author
        ]

        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
    }

    @objc func tapLikeButton(_ sender: UIButton) {

        guard let cardID = cards[currentCardIndex].cardID else {
            return Toast.showFailure(text: ToastText.failToLike.rawValue)
        }

        updateUserLikeCardList(visitorUid: SignInManager.shared.visitorUid ?? "", cardID: cardID, likeAction: .positive)
        updateCard(cardID: cardID, likeAction: .positive)
        cards[currentCardIndex].likeNumber += 1
        Toast.showSuccess(text: ToastText.successLike.rawValue)
    }

    @objc func tapWriteButton(_ sender: UIButton) {

        guard let writeVC =
                UIStoryboard.write.instantiateViewController(
                    withIdentifier: AddCardPostViewController.identifier
                ) as? AddCardPostViewController
        else { return }

        let navigationVC = BaseNavigationController(rootViewController: writeVC)
        writeVC.card = cards[currentCardIndex]
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true)
    }

    @objc func tapFavoriteButton(_ sender: UIBarButtonItem) {

        guard let favCardVC =
                UIStoryboard.card.instantiateViewController(
                    withIdentifier: FavoriteCardViewController.identifier
                ) as? FavoriteCardViewController
        else { return }

        show(favCardVC, sender: nil)
    }

    func setupCardView() {

        view.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            cardStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            cardStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ])
    }

    func setupLoadingAnimationView() {

        view.addSubview(loadingAnimationView)
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingAnimationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            loadingAnimationView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
        ])
    }

    func setupButtons() {

        let buttons = [shareButton, likeButton, writeButton]
        buttons.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isEnabled = false
            $0.backgroundColor = .M1.withAlphaComponent(0.8)
            $0.cornerRadius = CornerRadius.standard.rawValue
        }

        writeButton.addTarget(self, action: #selector(tapWriteButton(_:)), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(tapLikeButton(_:)), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(tapShareButton(_:)), for: .touchUpInside)

        view.addSubview(likeNumberLabel)
        likeNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            likeButton.topAnchor.constraint(equalTo: cardStack.bottomAnchor, constant: 28),
            likeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            likeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            likeButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),

            shareButton.topAnchor.constraint(equalTo: likeButton.topAnchor),
            shareButton.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -24),
            shareButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            shareButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),

            writeButton.topAnchor.constraint(equalTo: likeButton.topAnchor),
            writeButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 24),
            writeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            writeButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),

            likeNumberLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor),
            likeNumberLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 12)
        ])
    }

    func setupResetButton() {

        view.addSubview(resetBackgroundView)
        view.addSubview(resetButton)

        resetButton.isHidden = !isLastCardSwiped

        resetBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        resetBackgroundView.backgroundColor = .M1
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(resetCards(_:)), for: .touchUpInside)
        resetButton.backgroundColor = .white

        resetBackgroundViewWidthHidden = resetBackgroundView.widthAnchor.constraint(equalToConstant: 0)
        resetBackgroundViewHeightHidden = resetBackgroundView.heightAnchor.constraint(equalToConstant: 0)
        resetBackgroundViewWidthHidden.isActive = !isLastCardSwiped
        resetBackgroundViewHeightHidden.isActive = !isLastCardSwiped

        resetBackgroundViewWidth = resetBackgroundView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2)
        resetBackgroundViewHeight = resetBackgroundView.heightAnchor.constraint(
            equalTo: view.heightAnchor,
            multiplier: 2
        )
        resetBackgroundViewWidth.isActive = isLastCardSwiped
        resetBackgroundViewHeight.isActive = isLastCardSwiped

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

    func setupEducationView() {

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

        titleLabel.text = "試試看左右滑動片語"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.setBold(size: 24)
        okButton.setTitle("好喔", for: .normal)
        okButton.setTitleColor(.black, for: .normal)
        okButton.backgroundColor = .white.withAlphaComponent(0.8)
        okButton.titleLabel?.font = UIFont.setBold(size: 20)
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

    @objc func dismissEducationAnimation(_ sender: UIButton) {

        educationDimmingView.removeFromSuperview()
    }

    func setupNavigation() {

        navigationItem.title = "片語"
        navigationItem.setupRightBarButton(
            image: UIImage.sfsymbol(.bookmarkSelected),
            text: nil, target: self,
            action: #selector(tapFavoriteButton(_:)),
            color: .M1)
    }

    func setupExpandAnimation() {

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
