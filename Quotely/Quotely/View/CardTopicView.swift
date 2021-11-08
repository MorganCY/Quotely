//
//  CardTopicView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/8.
//

import Foundation
import UIKit

protocol CardTopicViewDelegate: AnyObject {

    func didSelectCard(_ view: CardTopicView)
}

class CardTopicView: UIView {

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

    init(content: String, author: String) {
        super.init(frame: .zero)
        setupViews(content: content, author: author)
        configureImageButtons()
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

    func setupViews(content: String, author: String) {

        let views = [contentLabel, authorLabel, cardImageView]
        views.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.textColor = .black
        authorLabel.text = author
        authorLabel.font = UIFont.systemFont(ofSize: 12)
        authorLabel.textColor = .gray

        cardImageView.setSpecificCorner(corners: [.topRight, .bottomRight])
        cardImageView.image = UIImage.asset(.bg4)
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.clipsToBounds = true

        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            authorLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24),
            authorLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            cardImageView.topAnchor.constraint(equalTo: topAnchor),
            cardImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35),
            cardImageView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }

    func configureImageButtons() {

        imageButtons.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.borderColor = .white
            $0.borderWidth = 1
            $0.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
            $0.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
            $0.bottomAnchor.constraint(equalTo: topAnchor, constant: -8).isActive = true
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
            bg4ImageButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            bg3ImageButton.trailingAnchor.constraint(equalTo: bg4ImageButton.leadingAnchor, constant: -6),
            bg2ImageButton.trailingAnchor.constraint(equalTo: bg3ImageButton.leadingAnchor, constant: -6),
            bg1ImageButton.trailingAnchor.constraint(equalTo: bg2ImageButton.leadingAnchor, constant: -6)
        ])
    }
}
