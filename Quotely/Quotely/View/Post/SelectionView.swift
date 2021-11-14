//
//  SelectionView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/26.
//

import Foundation
import UIKit

@objc enum ButtonStyle: Int {

    case text

    case image
}

// MARK: Protocol

@objc protocol SelectionViewDataSource: AnyObject {

    // swiftlint:disable identifier_name
    @objc func buttonStyle(_ view: SelectionView) -> ButtonStyle

    @objc func numberOfButtonsAt(_ view: SelectionView) -> Int

    @objc optional func buttonTitle(_ view: SelectionView, index: Int) -> String

    @objc optional func buttonTitleFont(_ view: SelectionView) -> UIFont

    @objc optional func buttonImage(_ view: SelectionView, index: Int) -> UIImage

    @objc func buttonColor(_ view: SelectionView) -> UIColor

    @objc func indicatorColor(_ view: SelectionView) -> UIColor

    @objc func indicatorWidth(_ view: SelectionView) -> CGFloat

    @objc optional func heightForButton(_ view: SelectionView) -> CGFloat
}

// MARK: Delegate
@objc protocol SelectionViewDelegate: AnyObject {

    @objc optional func didSelectButtonAt(_ view: SelectionView, at index: Int)

    @objc optional func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool
}

class SelectionView: UIView {

    weak var dataSource: SelectionViewDataSource? {

        didSet {

            setupStackView()

            setupButton()

            setupIndicator()
        }
    }

    weak var delegate: SelectionViewDelegate?

    var indicatorCenterX: NSLayoutConstraint!

    lazy var stackView: UIStackView = {

        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    lazy var indicator: UIView = {

        let indicator = UIView()

        indicator.translatesAutoresizingMaskIntoConstraints = false

        return indicator
    }()

    var buttons = [UIButton]()

    override init(frame: CGRect) {

        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    private func setupStackView() {

        addSubview(stackView)

        NSLayoutConstraint.activate([

            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),

            stackView.topAnchor.constraint(equalTo: self.topAnchor),

            stackView.widthAnchor.constraint(equalTo: self.widthAnchor),

            stackView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }

    private func setupButton() {

        for i in 0..<(dataSource?.numberOfButtonsAt(self) ?? 2) {

            let button = UIButton()

            buttons.append(button)

            stackView.addArrangedSubview(button)

            stackView.distribution = .equalSpacing

            button.translatesAutoresizingMaskIntoConstraints = false

            button.addTarget(self, action: #selector(didSelectButton(_:)), for: .touchUpInside)

            switch dataSource?.buttonStyle(self) {

            case .text:

                guard let buttonTitle = dataSource?.buttonTitle?(self, index: i) else { return }

                button.setTitle(buttonTitle, for: .normal)

                button.setTitleColor(dataSource?.buttonColor(self), for: .normal)

                button.titleLabel?.font = dataSource?.buttonTitleFont(self)

                NSLayoutConstraint.activate([

                    button.topAnchor.constraint(equalTo: stackView.topAnchor),

                    button.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: CGFloat(1.0 / Double((
                        dataSource?.numberOfButtonsAt(self) ?? 2)))),

                    button.heightAnchor.constraint(equalToConstant: dataSource?.heightForButton(self) ?? 0)
                ])

            case .image:

                guard let buttonImage = dataSource?.buttonImage?(self, index: i) else { return }

                button.setBackgroundImage(buttonImage, for: .normal)

                button.contentMode = .scaleAspectFit

                button.tintColor = dataSource?.buttonColor(self)

                NSLayoutConstraint.activate([

                    button.topAnchor.constraint(equalTo: stackView.topAnchor),

                    button.heightAnchor.constraint(equalTo: self.heightAnchor),

                    button.widthAnchor.constraint(equalTo: button.heightAnchor)
                ])

            default:

                break
            }
        }
    }

    private func setupIndicator() {

        stackView.addSubview(indicator)

        indicator.backgroundColor = dataSource?.indicatorColor(self)

        indicatorCenterX = indicator.centerXAnchor.constraint(equalTo: buttons[0].centerXAnchor)

        indicatorCenterX.isActive = true

        NSLayoutConstraint.activate([

            indicator.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 2),

            indicator.heightAnchor.constraint(equalToConstant: 3)
        ])

        guard let dataSource = dataSource else { return }

        NSLayoutConstraint.activate([

            indicator.widthAnchor.constraint(
                equalTo: buttons[0].widthAnchor,
                multiplier: dataSource.indicatorWidth(self)
            )
        ])
    }

    private(set) var selectedIndex = 0

    @objc func didSelectButton(_ sender: UIButton) {

        guard let senderIndex = buttons.firstIndex(of: sender) else { return }

        selectedIndex = senderIndex

        guard let shouldSelect = delegate?.shouldSelectButtonAt?(self, at: senderIndex) else { return }

        if shouldSelect {

            delegate?.didSelectButtonAt?(self, at: senderIndex)

            UIView.animate(

                withDuration: 0.15, delay: 0,

                options: .curveEaseIn,

                animations: {

                    self.indicatorCenterX.isActive = false

                    self.indicatorCenterX = self.indicator.centerXAnchor.constraint(equalTo: sender.centerXAnchor)

                    self.indicatorCenterX.isActive = true

                    self.layoutIfNeeded()

                }, completion: nil
            )
        }
    }
}

// MARK: ProtocolExtension
extension SelectionViewDataSource {

    func buttonTitleFont(_ view: SelectionView) -> UIFont {

        UIFont.systemFont(ofSize: 18)
    }

    func heightForButton(_ view: SelectionView) -> CGFloat {

        CGFloat(20)
    }
}
