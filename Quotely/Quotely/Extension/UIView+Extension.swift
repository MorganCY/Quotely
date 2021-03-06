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

        var arr: CACornerMask = []

        let allCorners: [UIRectCorner] = [.topLeft, .topRight, .bottomLeft, .bottomRight]

        for corner in allCorners {
            if corners.contains(corner) {
                switch corner {
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

// Convert View to Image
extension UIView {

    func convertToImage() -> UIImage {

        let imageRenderer = UIGraphicsImageRenderer(bounds: bounds)

        if let format = imageRenderer.format as? UIGraphicsImageRendererFormat {
            format.opaque = true
        }

        let image = imageRenderer.image { context in
            return layer.render(in: context.cgContext)
        }

        return image
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

    func dropShadow(opacity: Float = 0.3, width: Int = 4, height: Int = 4, radius: CGFloat = 8, isPath: Bool = true) {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: width, height: height)
        layer.shadowRadius = radius
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        if isPath { layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath }
    }
}

extension UIView {

    func fadeInAnimation(duration: Double) {

        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: {

                self.alpha = 1.0

            }, completion: nil
        )
    }
}
