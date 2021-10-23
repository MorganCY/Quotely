//
//  UIView+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

enum CornerRadius: CGFloat {

    case standard = 10.0
}

extension UIView {

    // Border Color
    @IBInspectable var borderColor: UIColor? {
        get {

            guard let borderColor = layer.borderColor else {

                return nil
            }

            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    // Border width
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    // Corner radius
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    // Shadow settings
    @IBInspectable var shadowColor: CGColor? {
        get {
            return layer.shadowColor
        }
        set {
            layer.shadowColor = newValue
        }
    }

    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable var shadowOffset: CGSize {
        get {
            return CGSize()
        }
        set {
            layer.shadowOffset = newValue
        }
    }
}

extension UIView {

    func stickSubView(_ objectView: UIView) {

        objectView.removeFromSuperview()

        addSubview(objectView)

        objectView.translatesAutoresizingMaskIntoConstraints = false

        objectView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true

        objectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

        objectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        objectView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100).isActive = true
    }
}
