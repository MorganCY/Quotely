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

    let backgroundImageView = UIImageView()
    let overlayView = UIView()
    let contentLabel = UILabel()
    let authorLabel = UILabel()
    let likeImageView = UIImageView()

    var hasLiked = true

    let theresoldMargin = (UIScreen.main.bounds.size.width/2) * 0.75
    let stength: CGFloat = 4
    let range: CGFloat = 0.90
    var xCenter: CGFloat = 0.0
    var yCenter: CGFloat = 0.0
    var originPoint = CGPoint.zero

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

    // MARK: SetupView

    func setupView() {
        cornerRadius = CornerRadius.standard.rawValue
        layer.shadowRadius = 3
        shadowOpacity = 0.4
        shadowOffset = CGSize(width: 0.5, height: 3)
        shadowColor = UIColor.darkGray.cgColor
        layer.shouldRasterize = true
        borderWidth = 0.5
        borderColor = .gray

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragged(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }

    func setupBackground() {

        addSubview(backgroundImageView)
        addSubview(overlayView)

        overlayView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.image = UIImage.asset(.bg1)
        backgroundImageView.cornerRadius = CornerRadius.standard.rawValue
        backgroundImageView.clipsToBounds = true
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.5
        overlayView.cornerRadius = CornerRadius.standard.rawValue

        NSLayoutConstraint.activate([

            backgroundImageView.widthAnchor.constraint(equalTo: self.widthAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            backgroundImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgroundImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            overlayView.widthAnchor.constraint(equalTo: self.widthAnchor),
            overlayView.heightAnchor.constraint(equalTo: self.heightAnchor),
            overlayView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            overlayView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    func setupContent() {

        addSubview(contentLabel)
        addSubview(authorLabel)

        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .white
        contentLabel.font = UIFont(name: "PingFang TC", size: 20)
        contentLabel.numberOfLines = 0
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.textColor = .white
        authorLabel.font = UIFont(name: "PingFang TC", size: 16)
        authorLabel.numberOfLines = 1

        NSLayoutConstraint.activate([
            contentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.75),

            authorLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
    }

    func setupLikeImageView() {

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

    func setupLikeStatus(isLeft: Bool) {

        likeImageView.image = isLeft
        ? UIImage.asset(.dislike) : UIImage.asset(.like)

        likeImageView.tintColor = isLeft
        ? .systemGreen : .systemPink

        guard let superview = superview else { return }

        likeImageView.alpha = abs(center.x - superview.center.x) / superview.center.x
    }

    // When card goes left
    func goesLeft() {

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
    func goesRight() {

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

    /*
    @objc func drag(_ sender: UIPanGestureRecognizer) {

        let point = sender.translation(in: self)

        guard let superview = superview else { return }
        center = CGPoint(x: superview.center.x + point.x, y: superview.center.y + point.y)

        let xFromCenter = self.center.x - superview.center.x

        likeImageView.image = {

            switch xFromCenter > 0 {

            case true:
                likeImageView.tintColor = .red
                return UIImage.asset(.like)

            case false:
                likeImageView.tintColor = .green
                return UIImage.asset(.dislike)
            }
        }()

        likeImageView.alpha = abs(xFromCenter) / superview.center.x

        if sender.state == .ended {

            UIView.animate(withDuration: 1 / 3) {

                self.center = superview.center
                self.likeImageView.alpha = 0
            }
        }
    }
     */
}

extension SwipeCardView: UIGestureRecognizerDelegate {

    @objc func dragged(_ sender: UIPanGestureRecognizer) {

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

    func afterSwipeAction() {

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
