//
//  ImageViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/12/1.
//

import Foundation
import UIKit

class ImageDetailViewController: UIViewController {
    var imageURL: URL?
    let imageView = UIImageView()
    var imageUrl: String?

    convenience init(imageUrl: String) {
        self.init()
        self.imageUrl = imageUrl
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func setupNavigation() {
        navigationItem.title = "查看圖片"
        navigationController?.setupBackButton(color: .gray)
    }

    func setupImage() {

        if let imageUrl = imageUrl {

            imageView.loadImage(imageUrl, placeHolder: nil)
            imageView.contentMode = .scaleAspectFit

            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            view.backgroundColor = .white

            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                imageView.topAnchor.constraint(equalTo: view.topAnchor)
            ])
        }
    }
}
