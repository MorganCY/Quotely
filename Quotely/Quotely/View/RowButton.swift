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
    private let title = UILabel()

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

        addSubview(iconBackgroundView)
        addSubview(iconImageView)
        addSubview(title)

        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            iconBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            iconBackgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            iconBackgroundView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7),
            iconBackgroundView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7),

            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalTo: iconBackgroundView.heightAnchor, multiplier: 0.7),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            title.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 24)
        ])

        iconImageView.image = image
        iconBackgroundView.backgroundColor = imageColor
        iconImageView.tintColor = .white

        title.tintColor = labelColor
        title.text = text
        title.font = UIFont.systemFont(ofSize: 18)
    }
}
