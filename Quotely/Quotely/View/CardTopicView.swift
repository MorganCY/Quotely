//
//  CardTopicView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/8.
//

import Foundation
import UIKit

protocol CardTopicViewDataSource: AnyObject {

    func getCardImage(_ view: CardTopicView) -> UIImage
}

protocol CardTopicViewDelegate: AnyObject {

    func didSelectCard(_ view: CardTopicView)
}

extension CardTopicViewDataSource {

    func getCardImage(_ view: CardTopicView) -> UIImage { return UIImage.asset(.bg4)! }
}

class CardTopicView: UIView {

    weak var dataSource: CardTopicViewDataSource? {
        didSet {
            DispatchQueue.main.async {
                self.setupViews()
                self.configureImageButtons()
            }
        }
    }

    let backgroundView = UIView()
    let contentLabel = UILabel()
    let authorLabel = UILabel()
    let cardImageView = UIImageView()
    let bg1ImageButton = UIButton()
    let bg2ImageButton = UIButton()
    let bg3ImageButton = UIButton()
    let bg4ImageButton = UIButton()
    var imageButtons: [UIButton] {
        return [bg1ImageButton, bg2ImageButton, bg3ImageButton, bg4ImageButton]
    }

    init(content: String, author: String, hasButton: Bool = true) {
        super.init(frame: .zero)
        contentLabel.text = content
        authorLabel.text = author
        if hasButton == false {
            imageButtons.forEach { $0.isHidden = true }
        }
    }

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageButtons.forEach { $0.cornerRadius = $0.frame.width / 2 }
    }

    @objc func changeTemplateImageToBg1(_ sender: UIButton) { cardImageView.image = UIImage.asset(.bg1) }
    @objc func changeTemplateImageToBg2(_ sender: UIButton) { cardImageView.image = UIImage.asset(.bg2) }
    @objc func changeTemplateImageToBg3(_ sender: UIButton) { cardImageView.image = UIImage.asset(.bg3) }
    @objc func changeTemplateImageToBg4(_ sender: UIButton) { cardImageView.image = UIImage.asset(.bg4) }

    func setupViews() {

        let views = [backgroundView, contentLabel, authorLabel, cardImageView]
        views.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        backgroundView.cornerRadius = CornerRadius.standard.rawValue
        backgroundView.borderWidth = 0.5
        backgroundView.borderColor = .lightGray
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textColor = .black
        contentLabel.numberOfLines = 0
        authorLabel.font = UIFont.systemFont(ofSize: 10)
        authorLabel.textColor = .lightGray
        authorLabel.numberOfLines = 1

        cardImageView.setSpecificCorner(corners: [.topRight, .bottomRight])
        cardImageView.image = dataSource?.getCardImage(self)
        cardImageView.contentMode = .scaleAspectFill
        cardImageView.clipsToBounds = true

        NSLayoutConstraint.activate([

            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),

            cardImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            cardImageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            cardImageView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.4),
            cardImageView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor),

            contentLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: cardImageView.leadingAnchor, constant: -16),

            authorLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            authorLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -16),
            authorLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1)
        ])
    }

    func configureImageButtons() {

        imageButtons.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
            $0.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
            $0.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 8).isActive = true
            $0.clipsToBounds = true
            $0.imageView?.contentMode = .scaleToFill
        }

        bg1ImageButton.setBackgroundImage(UIImage.asset(.bg1), for: .normal)
        bg2ImageButton.setBackgroundImage(UIImage.asset(.bg2), for: .normal)
        bg3ImageButton.setBackgroundImage(UIImage.asset(.bg3), for: .normal)
        bg4ImageButton.setBackgroundImage(UIImage.asset(.bg4), for: .normal)

        bg1ImageButton.addTarget(self, action: #selector(changeTemplateImageToBg1(_:)), for: .touchUpInside)
        bg2ImageButton.addTarget(self, action: #selector(changeTemplateImageToBg2(_:)), for: .touchUpInside)
        bg3ImageButton.addTarget(self, action: #selector(changeTemplateImageToBg3(_:)), for: .touchUpInside)
        bg4ImageButton.addTarget(self, action: #selector(changeTemplateImageToBg4(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            bg4ImageButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            bg3ImageButton.trailingAnchor.constraint(equalTo: bg4ImageButton.leadingAnchor, constant: -6),
            bg2ImageButton.trailingAnchor.constraint(equalTo: bg3ImageButton.leadingAnchor, constant: -6),
            bg1ImageButton.trailingAnchor.constraint(equalTo: bg2ImageButton.leadingAnchor, constant: -6)
        ])
    }
}
