//
//  EditOptionView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

class EditOptionView: UIView {

    private let socialShareButton = UIButton()

    private let cameraScanButton = UIButton()

    private let photoUploadButton = UIButton()

    private let stackView = UIStackView()

    init() {
        super.init(frame: .zero)

        setupButtons()
    }

    override func layoutSubviews() {

        layoutButtonIcons()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    func setupButtons() {

        let buttons = [socialShareButton, cameraScanButton, photoUploadButton]

        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        buttons.forEach {

            stackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageView?.contentMode = .scaleAspectFit
        }

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),

            socialShareButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.85),
            socialShareButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
            cameraScanButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.85),
            cameraScanButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
            photoUploadButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.85),
            photoUploadButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3)
        ])
    }

    func layoutButtonIcons() {

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: socialShareButton.frame.width, weight: .regular, scale: .large)

        socialShareButton.setImage(UIImage.sfsymbol(.shareNormal)?.withConfiguration(symbolConfig), for: .normal)
        cameraScanButton.setImage(UIImage.sfsymbol(.cameraNormal)?.withConfiguration(symbolConfig), for: .normal)
        photoUploadButton.setImage(UIImage.sfsymbol(.photo)?.withConfiguration(symbolConfig), for: .normal)
    }
}
