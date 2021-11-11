//
//  CardWriteViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/9.
//

import Foundation
import UIKit

class CardWriteViewController: BaseWriteViewController {

    var contentFromFavCard = "" {
        didSet {
            contentTextView.text = contentFromFavCard
        }
    }

    private let cardTopicTitleLabel = UILabel()
    private var cardTopicView = CardTopicView(content: "", author: "")

    override var uploadedImage: UIImage {
        didSet {
            cardTopicView.dataSource = self
        }
    }

    override var card: Card? {
        didSet {
            guard let card = card else { return }
            cardTopicView = CardTopicView(content: card.content, author: card.author)
        }
    }

    override var hasPostImage: Bool {
        get { true }
        // swiftlint:disable unused_setter_value
        set {}
    }

    override var cardHandler: ()? {

        get {

            CardManager.shared.updateCardPostList(
                cardID: card?.cardID ?? "",
                postID: onPublishPostID ?? ""
            ) { result in

                switch result {

                case .success(let success):
                    print(success)

                    Toast.shared.hud.dismiss()

                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

                    let tabBar = sceneDelegate?.window?.rootViewController as? UITabBarController

                    sceneDelegate?.window?.rootViewController?.dismiss(animated: true, completion: {

                        tabBar?.selectedIndex = 2
                    })

                case .failure(let error):
                    print(error)

                    Toast.showFailure(text: "上傳失敗")
                }
            }
        }
        // swiftlint:disable unused_setter_value
        set {}
    }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cardTopicView.dataSource = self
        layoutCardView()
    }
}

extension CardWriteViewController: CardTopicViewDataSource {

    func getCardImage(_ view: CardTopicView) -> UIImage { uploadedImage }
}

extension CardWriteViewController {

    func layoutCardView() {

        let views = [ cardTopicTitleLabel, cardTopicView ]

        views.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        cardTopicTitleLabel.text = "引用片語"
        cardTopicTitleLabel.numberOfLines = 1
        cardTopicTitleLabel.textColor = .M1
        cardTopicTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)

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
