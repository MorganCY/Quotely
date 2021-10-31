//
//  ContentTextView.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/26.
//

import Foundation
import UIKit

class ContentTextView: UITextView {

    init(bgColor: UIColor = UIColor.gray) {
        super.init(frame: .zero, textContainer: nil)
        font = UIFont.systemFont(ofSize: 18)
        backgroundColor = bgColor.withAlphaComponent(0.2)
        cornerRadius = CornerRadius.standard.rawValue
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
