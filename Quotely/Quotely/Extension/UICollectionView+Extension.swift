//
//  UICollectionView+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/27.
//

import UIKit

extension UICollectionView {

    func registerCellWithNib(identifier: String, bundle: Bundle?) {

        let nib = UINib(nibName: identifier, bundle: bundle)

        register(nib, forCellWithReuseIdentifier: identifier)
    }
}

extension UICollectionViewCell {

    static var identifier: String {

        return String(describing: self)
    }
}
