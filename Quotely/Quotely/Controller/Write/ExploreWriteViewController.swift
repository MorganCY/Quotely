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

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        deleteImageButton.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutPostImage()

        setupPostImageViews()
    }

    @objc func deleteImage(_ sender: UIButton) {
        postImageView.image = nil
        hasPostImage = false
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

    func setupPostImageViews() {

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 10

        deleteImageButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        deleteImageButton.backgroundColor = .clear
    }
}
