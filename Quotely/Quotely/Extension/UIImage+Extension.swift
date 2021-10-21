//
//  UIImage+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

enum ImageAsset: String {

    case testProfile = "test_profile"
}

enum SFSymbol: String {

    case newspaperNormal = "newspaper"

    case newpaperSelected = "newspaper.fill"

    case shareNormal = "square.and.arrow.up"

    case cameraNormal = "camera"

    case photo = "photo"

    case person = "person"

    case heartNormal = "heart"

    case heartSelected = "heart.fill"

    case send = "paperplane.fill"
}

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }

    static func sfsymbol(_ systemName: SFSymbol) -> UIImage? {

        return UIImage(systemName: systemName.rawValue)
    }
}

extension UIImage {

    func scale(newWidth: CGFloat) -> UIImage {

        if self.size.width == newWidth {

            return self
        }

        let scaleFactor = newWidth / self.size.width

        let newHeight = self.size.height * scaleFactor

        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(
            newSize, false, 0.0
        ); self.draw(in: CGRect(
            x: 0, y: 0, width: newWidth, height: newHeight
        ))

        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return newImage ?? self
    }
}
