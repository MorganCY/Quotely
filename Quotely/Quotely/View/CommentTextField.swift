//
//  CommentTextField.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/21.
//

import UIKit

class CommentTextField: UITextField {

    init() {
        super.init(frame: .zero)
        placeholder = "  說點什麼..."
        font = UIFont.setRegular(size: 18)
        keyboardType = UIKeyboardType.default
        clearButtonMode = UITextField.ViewMode.whileEditing
        contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        backgroundColor = UIColor.gray.withAlphaComponent(0.2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        cornerRadius = self.frame.height / 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
