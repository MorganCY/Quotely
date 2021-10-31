//
//  UIView+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

enum CornerRadius: CGFloat {

    case standard = 15.0
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

    func setSpecificCorner(radius: CGFloat = CornerRadius.standard.rawValue, corners: UIRectCorner) {

        self.layer.cornerRadius = radius

        if #available(iOS 11.0, *) {

            var arr: CACornerMask = []

            let allCorners: [UIRectCorner] = [.topLeft, .topRight, .bottomLeft, .bottomRight]

            for corn in allCorners {
                if corners.contains(corn) {
                    switch corn {
                    case .topLeft:
                        arr.insert(.layerMinXMinYCorner)
                    case .topRight:
                        arr.insert(.layerMaxXMinYCorner)
                    case .bottomLeft:
                        arr.insert(.layerMinXMaxYCorner)
                    case .bottomRight:
                        arr.insert(.layerMaxXMaxYCorner)
                    default: break
                    }
                }
            }

            self.layer.maskedCorners = arr

        } else {

            self.roundCornersBezierPath(corners: corners, radius: radius)
        }
    }

    private func roundCornersBezierPath(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
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

        objectView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

// Shadow settings
extension UIView {

    func dropShadow(opacity: Float = 0.3, width: Int = 4, height: Int = 4, radius: CGFloat = 8) {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: width, height: height)
        layer.shadowRadius = radius
//        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

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
