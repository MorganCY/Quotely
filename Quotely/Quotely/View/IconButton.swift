//
//  IconButton.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/21.
//

import UIKit

class ImageButton: UIButton {

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

    init(color: UIColor) {
        super.init(frame: .zero)
        font = UIFont.systemFont(ofSize: 14)
        textColor = color
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
