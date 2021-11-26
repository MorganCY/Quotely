//
//  CardWriteViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/9.
//

import Foundation
import UIKit

class CardWriteViewController: BaseWriteViewController {

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
                self.cardTopicView.dataSource = self
            }
        }
    }
    override var imageUrl: String? {
        didSet {
            if imageUrl != nil { cardTopicView.dataSource = self }
        }
    }

    var contentFromFavCard = "" {
        didSet {
            contentTextView.text = contentFromFavCard
        }
    }

    override var hasPostImage: Bool {
        get { true }
        // swiftlint:disable unused_setter_value
        set {}
    }

    private let cardTopicTitleLabel = UILabel()
    private var cardTopicView = CardTopicView(content: "", author: "")

    override var cardPostHandler: ()? {

        get {

            CardManager.shared.updateCardPostList(
                cardID: card?.cardID ?? "",
                postID: onPublishPostID ?? ""
            ) { result in

                switch result {

                case .success(let success):
                    print(success)

                    DispatchQueue.main.async { Toast.shared.hud.dismiss() }

                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

                    let tabBar = sceneDelegate?.window?.rootViewController as? UITabBarController

                    sceneDelegate?.window?.rootViewController?.dismiss(animated: true, completion: {

                        tabBar?.selectedIndex = 2
                    })

                case .failure(let error):
                    print(error)

                    DispatchQueue.main.async { Toast.showFailure(text: "上傳失敗") }
                }
            }
        }
        // swiftlint:disable unused_setter_value
        set {}
    }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCardTopicView()
    }
}

extension CardWriteViewController: CardTopicViewDataSource, CardTopicViewDelegate {

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

extension CardWriteViewController {

    func setupCardTopicView() {

        let views = [cardTopicTitleLabel, cardTopicView]

        views.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        cardTopicView.dataSource = self
        cardTopicView.delegate = self

        cardTopicTitleLabel.text = "引用片語"
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
