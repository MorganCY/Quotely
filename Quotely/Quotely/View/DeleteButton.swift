//
//  DeleteButton.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/22.
//

import UIKit

class DeleteButton: UIButton {

    init() {
        super.init(frame: .zero)
        setBackgroundImage(UIImage.sfsymbol(.closeButton), for: .normal)
        backgroundColor = . white
        tintColor = .black
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
