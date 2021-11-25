//
//  IconButton.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/21.
//

import UIKit

class ImageButton: UIButton {

    private let iconImageView = UIImageView()
    private let buttonLabel = UILabel()

    init(
        image: UIImage,
        color: UIColor,
        bgColor: UIColor = .clear,
        labelTitle: String? = nil,
        labelColor: UIColor? = nil,
        fontSize: CGFloat = 14
    ) {
        super.init(frame: .zero)

        setUpButton(image: image, tintColor: color, labelTitle: labelTitle, labelColor: labelColor, fontSize: fontSize)
        backgroundColor = bgColor
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setUpButton(image: UIImage, tintColor: UIColor, labelTitle: String?, labelColor: UIColor?, fontSize: CGFloat) {

        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = image
        iconImageView.tintColor = tintColor

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
        ])

        if let labelTitle = labelTitle,
           let labelColor = labelColor {

            addSubview(buttonLabel)
            buttonLabel.translatesAutoresizingMaskIntoConstraints = false
            buttonLabel.text = labelTitle
            buttonLabel.textColor = labelColor
            buttonLabel.font = UIFont.setRegular(size: fontSize)

            NSLayoutConstraint.activate([

                buttonLabel.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
                buttonLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: 12)
            ])
        }
    }
}

class ImageButtonLabel: UILabel {

    init(color: UIColor) {
        super.init(frame: .zero)
        font = UIFont.setRegular(size: 14)
        textColor = color
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension ImageButton {
    override open var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.alpha = 1.0
            } else {
                self.alpha = 0.3
            }
            self.layoutIfNeeded()
        }
    }
}
