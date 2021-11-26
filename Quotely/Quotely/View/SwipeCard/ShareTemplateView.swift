//
//  FullImageTemplateView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/2.
//

import Foundation
import UIKit

protocol ShareTemplateViewDataSource: AnyObject {

    func imageOfTemplateContent(_ view: ShareTemplateView) -> UIImage
}

extension ShareTemplateViewDataSource {

    func imageOfTemplateContent(_ view: ShareTemplateView) -> UIImage { UIImage.asset(.bg4) }
}

class ShareTemplateView: UIView {

    enum TemplateType {
        case fullImage
        case halfImage
        case smallImage
    }

    weak var dataSource: ShareTemplateViewDataSource? {
        didSet {
            DispatchQueue.main.async {
                self.templateImageView.image = self.dataSource?.imageOfTemplateContent(self)
                self.smallImageView.image = self.dataSource?.imageOfTemplateContent(self)
            }
        }
    }

    private let templateImageView = UIImageView()
    private let smallImageView = UIImageView()
    private let textBackgroundView = UIView()
    private let contentLabel = UILabel()
    private let authorLabel = UILabel()
    private let quotelyLabel = UILabel()

    init(type: TemplateType, content: String, author: String) {
        super.init(frame: .zero)

        backgroundColor = .white
        contentLabel.text = content
        authorLabel.text = author
        configureView(templateType: type)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        smallImageView.cornerRadius = smallImageView.frame.width / 2
    }

    private func configureView(templateType: TemplateType) {

        let basicViews = [templateImageView, textBackgroundView, quotelyLabel]
        let labels = [contentLabel, authorLabel]

        basicViews.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        labels.forEach {
            textBackgroundView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentLabel.font = UIFont.setRegular(size: 16)
        authorLabel.font = UIFont.setRegular(size: 14)
        quotelyLabel.font = UIFont.setRegular(size: 14)
        contentLabel.textColor = .black
        authorLabel.textColor = .gray
        contentLabel.numberOfLines = 0
        authorLabel.numberOfLines = 1
        quotelyLabel.textColor = .white

        templateImageView.contentMode = .scaleAspectFill
        templateImageView.clipsToBounds = true

        textBackgroundView.backgroundColor = .white
        textBackgroundView.cornerRadius = CornerRadius.standard.rawValue

        quotelyLabel.text = "分享自隻字片語App"

        switch templateType {

        case .fullImage:

            templateImageView.cornerRadius = CornerRadius.standard.rawValue

            NSLayoutConstraint.activate([

                templateImageView.topAnchor.constraint(equalTo: self.topAnchor),
                templateImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                templateImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                templateImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

                textBackgroundView.leadingAnchor.constraint(equalTo: templateImageView.leadingAnchor, constant: 24),
                textBackgroundView.trailingAnchor.constraint(equalTo: templateImageView.trailingAnchor, constant: -24),
                textBackgroundView.bottomAnchor.constraint(equalTo: templateImageView.bottomAnchor, constant: -32),

                contentLabel.leadingAnchor.constraint(equalTo: textBackgroundView.leadingAnchor, constant: 24),
                contentLabel.topAnchor.constraint(equalTo: textBackgroundView.topAnchor, constant: 24),
                contentLabel.trailingAnchor.constraint(equalTo: textBackgroundView.trailingAnchor, constant: -24),

                authorLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24),
                authorLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
                authorLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
                authorLabel.bottomAnchor.constraint(equalTo: textBackgroundView.bottomAnchor, constant: -24),
                authorLabel.heightAnchor.constraint(equalTo: textBackgroundView.heightAnchor, multiplier: 0.1),

                quotelyLabel.bottomAnchor.constraint(equalTo: textBackgroundView.topAnchor, constant: -8),
                quotelyLabel.trailingAnchor.constraint(equalTo: textBackgroundView.trailingAnchor)
            ])

        case .halfImage:

            templateImageView.setSpecificCorner(radius: CornerRadius.standard.rawValue, corners: [.topLeft, .topRight])

            NSLayoutConstraint.activate([

                templateImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                templateImageView.topAnchor .constraint(equalTo: self.topAnchor),
                templateImageView.widthAnchor.constraint(equalTo: self.widthAnchor),
                templateImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5),

                contentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
                contentLabel.topAnchor.constraint(equalTo: templateImageView.bottomAnchor, constant: 24),
                contentLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),

                authorLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24),
                authorLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
                authorLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
                authorLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -32),

                quotelyLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
                quotelyLabel.bottomAnchor.constraint(equalTo: templateImageView.bottomAnchor, constant: -8)
            ])

        case .smallImage:

            templateImageView.isHidden = true

            addSubview(smallImageView)
            smallImageView.translatesAutoresizingMaskIntoConstraints = false
            smallImageView.contentMode = .scaleAspectFill
            smallImageView.clipsToBounds = true
            contentLabel.textAlignment = .center
            authorLabel.textAlignment = .center
            quotelyLabel.textAlignment = .center
            quotelyLabel.textColor = .gray

            NSLayoutConstraint.activate([

                smallImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 32),
                smallImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                smallImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.45),
                smallImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.45),

                contentLabel.topAnchor.constraint(equalTo: smallImageView.bottomAnchor, constant: 32),
                contentLabel.centerXAnchor.constraint(equalTo: smallImageView.centerXAnchor),
                contentLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),

                authorLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24),
                authorLabel.centerXAnchor.constraint(equalTo: smallImageView.centerXAnchor),
                authorLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),

                quotelyLabel.centerXAnchor.constraint(equalTo: smallImageView.centerXAnchor),
                quotelyLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
                quotelyLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 24),
                quotelyLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -32)
            ])
        }
    }
}
