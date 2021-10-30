//
//  HashtagStackView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/30.
//

import Foundation
import UIKit

protocol HashtagViewDataSource: AnyObject {

    func numbersOfButtonsIn(_ view: HashtagView) -> Int

    func buttonTitle(_ view: HashtagView, index: Int) -> String
}

protocol HashtagViewDelegate: AnyObject {

    func didSelectButtonAt(_ view: HashtagView, index: Int)

    func didSelectAddHashtagButton(_ view: HashtagView)
}

class HashtagView: UIView {

    weak var dataSource: HashtagViewDataSource? {

        didSet {

            setupHashtags()
        }
    }
    weak var delegate: HashtagViewDelegate?

    private var buttons = [UIButton]()
    private let stackView = UIStackView()
    private let addHashTagButton = UIButton()

    init() {
        super.init(frame: .zero)
        setupStackView()
        setupAddHashtagButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func reloadData() {

        setupHashtags()
    }

    private func setupStackView() {

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 3

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }

    private func setupAddHashtagButton() {

        addSubview(addHashTagButton)

        addHashTagButton.translatesAutoresizingMaskIntoConstraints = false

        addHashTagButton.addTarget(self, action: #selector(didSelectHashtagButton(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            addHashTagButton.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 3),
            addHashTagButton.heightAnchor.constraint(equalToConstant: 32),
            addHashTagButton.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])

        addHashTagButton.setTitle(" 新增標籤＋ ", for: .normal)
        addHashTagButton.setTitleColor(.gray, for: .normal)
        addHashTagButton.cornerRadius = CornerRadius.standard.rawValue / 3
        addHashTagButton.borderColor = .gray
        addHashTagButton.borderWidth = 1
    }

    private func setupHashtags() {

        for index in 0..<(dataSource?.numbersOfButtonsIn(self) ?? 0) {

            guard let dataSource = dataSource else {

                return
            }

            let button = UIButton()

            buttons.append(button)

            stackView.addArrangedSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false

            button.setTitleColor(.white, for: .normal)

            button.backgroundColor = .gray

            button.setTitle(" \(dataSource.buttonTitle(self, index: index)) ", for: .normal)

            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)

            button.cornerRadius = CornerRadius.standard.rawValue / 3

            button.addTarget(self, action: #selector(didSelectButton(_:)), for: .touchUpInside)

            switch index {

            case 0:

                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: stackView.topAnchor),
                    button.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                    button.heightAnchor.constraint(equalToConstant: 32)
                ])

            default:

                NSLayoutConstraint.activate([
                    button.leadingAnchor.constraint(equalTo: buttons[index-1].trailingAnchor, constant: 3),
                    button.heightAnchor.constraint(equalToConstant: 32)
                ])
            }
        }
    }

    @objc func didSelectHashtagButton(_ sender: UIButton) {

        delegate?.didSelectAddHashtagButton(self)
    }

    private(set) var selectedIndex = 0

    @objc func didSelectButton(_ sender: UIButton) {

        guard let senderIndex = buttons.firstIndex(of: sender) else { return }

        selectedIndex = senderIndex

        buttons.remove(at: senderIndex)

        stackView.removeArrangedSubview(sender)

        delegate?.didSelectButtonAt(self, index: senderIndex)
    }
}
