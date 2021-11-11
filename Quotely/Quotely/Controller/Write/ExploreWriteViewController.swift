//
//  WriteViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import PhotosUI
import Vision

class ExploreWriteViewController: BaseWriteViewController {

    private var postImageView = UIImageView()
    private let deleteImageButton = DeleteButton()

    override var hasPostImage: Bool {
        didSet {
            DispatchQueue.main.async {
                self.deleteImageButton.isHidden = !self.hasPostImage
                self.quoteButton.isHidden = self.hasPostImage
            }
        }
    }

    override var uploadedImage: UIImage {
        didSet {
            DispatchQueue.main.async {
                self.postImageView.image = self.uploadedImage
            }
        }
    }

    private let quoteButton = RowButton(
        image: UIImage.sfsymbol(.quoteNormal)!,
        imageColor: .M3!,
        labelColor: .white,
        text: "引用我收藏的片語"
    )

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupQuoteButton()

        deleteImageButton.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutPostImage()
    }

    @objc func deleteImage(_ sender: UIButton) {
        postImageView.image = nil
        hasPostImage = false
    }

    @objc func goToFavoriteCardPage(_ sender: RowButton) {

        guard let favCardVC =
                UIStoryboard.card
                .instantiateViewController(
                    withIdentifier: String(describing: FavoriteCardViewController.self)
                ) as? FavoriteCardViewController else {

                    return
                }

        favCardVC.isFromWriteVC = true
        favCardVC.passedContentText = contentTextView.text

        let navigationVC = BaseNavigationController(rootViewController: favCardVC)

        present(navigationVC, animated: true)
    }
}

// MARK: SetupViews
extension ExploreWriteViewController {

    func layoutPostImage() {

        let views = [
            postImageView, deleteImageButton
        ]

        views.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 10

        deleteImageButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        deleteImageButton.backgroundColor = .clear

        NSLayoutConstraint.activate([

            postImageView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 24),
            postImageView.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            postImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            postImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),

            deleteImageButton.centerXAnchor.constraint(equalTo: postImageView.trailingAnchor),
            deleteImageButton.centerYAnchor.constraint(equalTo: postImageView.topAnchor),
            deleteImageButton.widthAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 0.15),
            deleteImageButton.heightAnchor.constraint(equalTo: deleteImageButton.widthAnchor)
        ])
    }

    func setupQuoteButton() {

        view.addSubview(quoteButton)
        quoteButton.translatesAutoresizingMaskIntoConstraints = false

        quoteButton.cornerRadius = CornerRadius.standard.rawValue
        quoteButton.backgroundColor = .M3!
        quoteButton.addTarget(self, action: #selector(goToFavoriteCardPage(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            quoteButton.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            quoteButton.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor),
            quoteButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
            quoteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
        ])
    }
}
