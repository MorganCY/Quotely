//
//  IconButton.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/21.
//

import UIKit

class IconButton: UIButton {

    init(image: UIImage, color: UIColor) {
        super.init(frame: .zero)
        setBackgroundImage(image, for: .normal)
        tintColor = color
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class IconButtonLabel: UILabel {

    init(text: String) {
        super.init(frame: .zero)
        font = UIFont.systemFont(ofSize: 12)
        textColor = .gray
        self.text = text
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
