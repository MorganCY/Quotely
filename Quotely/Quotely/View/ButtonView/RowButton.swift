//
//  File.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/30.
//

import Foundation
import UIKit

class RowButton: UIButton {

    private let iconBackgroundView = UIView()
    private let iconImageView = UIImageView()
    private let rowButttonTitleLabel = UILabel()
    private let nextImageView = UIImageView()

    init(image: UIImage, imageColor: UIColor, labelColor: UIColor = .black, text: String) {
        super.init(frame: .zero)

        layoutButton(image: image, imageColor: imageColor, labelColor: labelColor, text: text)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        iconBackgroundView.cornerRadius = iconBackgroundView.frame.width / 2
    }

    private func layoutButton(image: UIImage, imageColor: UIColor, labelColor: UIColor, text: String) {

        let views = [iconImageView, iconBackgroundView, rowButttonTitleLabel, nextImageView]
        views.forEach {
            insertSubview($0, at: 0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([

            iconBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 36),
            iconBackgroundView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            iconBackgroundView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),

            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalTo: iconBackgroundView.heightAnchor, multiplier: 0.7),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            rowButttonTitleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            rowButttonTitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 36),

            nextImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36),
            nextImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.05),
            nextImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.08),
            nextImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        iconImageView.image = image
        iconBackgroundView.backgroundColor = imageColor
        iconImageView.tintColor = .white

        rowButttonTitleLabel.textColor = labelColor
        rowButttonTitleLabel.text = text
        rowButttonTitleLabel.font = UIFont.setRegular(size: 18)

        nextImageView.image = UIImage.sfsymbol(.next)
        nextImageView.tintColor = labelColor
    }
}
