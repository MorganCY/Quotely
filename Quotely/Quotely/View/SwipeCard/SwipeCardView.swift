//
//  SwipeCardView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/23.
//

import Foundation
import UIKit

protocol SwipeCardViewDelegate: AnyObject {

    func cardGoesRight(_ card: SwipeCardView)

    func cardGoesLeft(_ card: SwipeCardView)
}

class SwipeCardView: UIView {

    weak var delegate: SwipeCardViewDelegate?

    private let backgroundImageView = UIImageView()
    private let textBackgroundView = UIView()
    let contentLabel = UILabel()
    let authorLabel = UILabel()
    private let likeImageView = UIImageView()
    private let backgroundImages: [ImageAsset] = [.bg1, .bg2, .bg3, .bg4]

    private var hasLiked = true

    private let theresoldMargin = (UIScreen.main.bounds.size.width/2) * 0.75
    private let stength: CGFloat = 4
    private let range: CGFloat = 0.90
    private var xCenter: CGFloat = 0.0
    private var yCenter: CGFloat = 0.0
    private var originPoint = CGPoint.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBackground()
        setupContent()
        setupLikeImageView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupLikeStatus(isLeft: Bool) {

        likeImageView.image = isLeft
        ? UIImage.asset(.dislike) : UIImage.asset(.like)

        likeImageView.tintColor = .M1

        guard let superview = superview else { return }

        likeImageView.alpha = abs(center.x - superview.center.x) / superview.center.x
    }

    // When card goes left
    private func goesLeft() {

        let finishPoint = CGPoint(
            x: -(frame.size.width * 2),
            y: yCenter * 2 + originPoint.y)

        delegate?.cardGoesLeft(self)

        UIView.animate(withDuration: 1 / 2) {

            self.center = finishPoint

        } completion: { _ in

            self.removeFromSuperview()

        }

        hasLiked = false
    }

    // When card goes right
    private func goesRight() {

        let finishPoint = CGPoint(
            x: frame.size.width * 2,
            y: yCenter * 2 + originPoint.y)

        delegate?.cardGoesRight(self)

        UIView.animate(withDuration: 1 / 2) {

            self.center = finishPoint

        } completion: { _ in

            self.removeFromSuperview()
        }

        hasLiked = true
    }
}

extension SwipeCardView: UIGestureRecognizerDelegate {

    @objc func dragCard(_ sender: UIPanGestureRecognizer) {

        xCenter = sender.translation(in: self).x
        yCenter = sender.translation(in: self).y

        if xCenter < 0 {
            setupLikeStatus(isLeft: true)
        } else if xCenter > 0 {
            setupLikeStatus(isLeft: false)
        }

        switch sender.state {

        case .began:
            originPoint = self.center

        case .changed:
            let rotationStrength = min(xCenter / UIScreen.main.bounds.size.width, 1)
            let rotationAngel = .pi / 8 * rotationStrength
            let scale = max(1 - abs(rotationStrength) / stength, range)
            center = CGPoint(x: originPoint.x + xCenter, y: originPoint.y + yCenter)

            let transforms = CGAffineTransform(rotationAngle: rotationAngel)
            let scaleTransform: CGAffineTransform = transforms.scaledBy(x: scale, y: scale)
            self.transform = scaleTransform

        case .ended:
            afterSwipeAction()

        case .possible: break
        case .cancelled: break
        case .failed: break
        default:
            fatalError()
        }
    }

    private func afterSwipeAction() {

        if xCenter > theresoldMargin {
            goesRight()
        } else if xCenter < -theresoldMargin {
            goesLeft()
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, animations: {
                self.center = self.originPoint
                self.transform = CGAffineTransform(rotationAngle: 0)
                self.likeImageView.alpha = 0
            })
        }
    }
}

extension SwipeCardView {

    private func setupView() {
        cornerRadius = CornerRadius.standard.rawValue
        layer.shadowRadius = 3
        layer.shouldRasterize = true
        borderWidth = 0.5
        borderColor = .gray

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragCard(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }

    private func setupBackground() {

        addSubview(backgroundImageView)
        addSubview(textBackgroundView)

        textBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.cornerRadius = CornerRadius.standard.rawValue
        backgroundImageView.clipsToBounds = true

        textBackgroundView.backgroundColor = .white
        textBackgroundView.cornerRadius = CornerRadius.standard.rawValue
        self.layer.shouldRasterize = false

        backgroundImageView.image = UIImage.asset(backgroundImages[Int.random(in: 0...3)])

        NSLayoutConstraint.activate([

            backgroundImageView.widthAnchor.constraint(equalTo: self.widthAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            backgroundImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgroundImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            textBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            textBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            textBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24)
        ])
    }

    private func setupContent() {

        textBackgroundView.addSubview(contentLabel)
        textBackgroundView.addSubview(authorLabel)

        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .black
        contentLabel.font = UIFont.setRegular(size: 16)
        contentLabel.numberOfLines = 0
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.textColor = .gray
        authorLabel.font = UIFont.setRegular(size: 12)
        authorLabel.numberOfLines = 1

        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: textBackgroundView.leadingAnchor, constant: 24),
            contentLabel.topAnchor.constraint(equalTo: textBackgroundView.topAnchor, constant: 32),
            contentLabel.trailingAnchor.constraint(equalTo: textBackgroundView.trailingAnchor, constant: -24),

            authorLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24),
            authorLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: textBackgroundView.bottomAnchor, constant: -24),
            authorLabel.heightAnchor.constraint(equalTo: textBackgroundView.heightAnchor, multiplier: 0.1)
        ])
    }

    private func setupLikeImageView() {

        addSubview(likeImageView)
        likeImageView.translatesAutoresizingMaskIntoConstraints = false
        likeImageView.alpha = 0

        NSLayoutConstraint.activate([
            likeImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            likeImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            likeImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            likeImageView.heightAnchor.constraint(equalTo: likeImageView.widthAnchor)
        ])
    }
}
