//
//  Kingfisher.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/19.
//

import UIKit
import Kingfisher

extension UIImageView {

    func loadImage(_ urlString: String, placeHolder: UIImage? = nil) {

        let url = URL(string: urlString)

        self.kf.indicatorType = .activity

        self.kf.setImage(with: url, placeholder: placeHolder)
    }
}
