//
//  CardWriteViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/9.
//

import Foundation
import UIKit

class AddCardPostViewController: BaseAddPostViewController {

    override var card: Card? {
        didSet {
            guard let card = card else { return }
            cardTopicView = CardTopicView(
                content: card.content.replacingOccurrences(of: "\\n", with: "\n"),
                author: card.author
            )
        }
    }

    override var uploadedImage: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.cardTopicView.layoutIfNeeded()
            }
        }
    }
    override var imageUrl: String? {
        didSet {
            if imageUrl != nil {
                cardTopicView.dataSource = self
            }
        }
    }
    var contentFromFavCard = "" {
        didSet {
            contentTextView.text = contentFromFavCard
        }
    }

    private let cardTopicTitleLabel = UILabel()
    private var cardTopicView = CardTopicView(content: "", author: "")

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hasPostImage = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCardTopicView()
    }

    override func updateUser(postID: String, action: FirebaseAction) {
        super.updateUser(postID: postID, action: action)

        updateCardPostList(cardID: self.card?.cardID ?? "", postID: postID)
    }

    func updateCardPostList(cardID: String, postID: String) {

        CardManager.shared.updateCardPostList(
            cardID: cardID, postID: postID
        ) { result in

            switch result {

            case .success(let success):
                print(success)
                Toast.shared.hud.dismiss()
                self.goToDesignatedTab(.explore)

            case .failure(let error):
                print(error)
                Toast.shared.showFailure(text: .failToUpload)
            }
        }
    }
}

extension AddCardPostViewController: CardTopicViewDataSource, CardTopicViewDelegate {

    func getCardImage(_ view: CardTopicView) -> UIImage? { uploadedImage }

    func getCardImageUrl(_ view: CardTopicView) -> String? {
        if let imageUrl = imageUrl {
            return imageUrl
        }
        return nil
    }

    func didSelectCard(_ view: CardTopicView, index: Int) {
        switch index {
        case 0: uploadedImage = UIImage.asset(.bg1)
        case 1: uploadedImage = UIImage.asset(.bg2)
        case 2: uploadedImage = UIImage.asset(.bg3)
        case 3: uploadedImage = UIImage.asset(.bg4)
        default: break
        }
    }
}

extension AddCardPostViewController {

    func setupCardTopicView() {

        let views = [cardTopicTitleLabel, cardTopicView]

        views.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        cardTopicView.dataSource = self
        cardTopicView.delegate = self

        cardTopicTitleLabel.text = "????????????"
        cardTopicTitleLabel.numberOfLines = 1
        cardTopicTitleLabel.textColor = .M1
        cardTopicTitleLabel.font = UIFont.setBold(size: 18)

        NSLayoutConstraint.activate([

            cardTopicTitleLabel.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 24),
            cardTopicTitleLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            cardTopicTitleLabel.heightAnchor.constraint(equalToConstant: 20),

            cardTopicView.topAnchor.constraint(equalTo: cardTopicTitleLabel.bottomAnchor, constant: 8),
            cardTopicView.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            cardTopicView.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor),
            cardTopicView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
    }
}
