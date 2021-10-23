//
//  SwipeViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/23.
//

import Foundation
import UIKit

class SwipeViewController: UIViewController {

    let cardStack = SwipeCardStackView()
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var optionPanel: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "瀏覽"

        setupOptionPanel()

        cardStack.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupCardView()
    }

    func setupCardView() {

        view.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            cardStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            cardStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            cardStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ])
    }

    func setupOptionPanel() {

        shareButton.setTitle("", for: .normal)
        likeButton.setTitle("", for: .normal)
        commentButton.setTitle("", for: .normal)
        optionPanel.shadowOpacity = 0.4
        optionPanel.shadowOffset = CGSize(width: 0.5, height: 3)
        optionPanel.shadowColor = UIColor.darkGray.cgColor
        optionPanel.layer.shouldRasterize = true
        optionPanel.cornerRadius = CornerRadius.standard.rawValue
    }
}

extension SwipeViewController: SwipeCardStackViewDataSource {

    func numbersOfCardsIn(_ stack: SwipeCardStackView) -> Int {

        2
    }
}
