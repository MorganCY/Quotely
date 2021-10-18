//
//  UIImage+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

enum ImageAsset: String {

    // Profile tab - Tab
    case none
}

enum SFSymbol: String {

    case newspaperNormal = "newspaper"

    case newpaperSelected = "newspaper.fill"

    case shareNormal = "square.and.arrow.up"

    case cameraNormal = "camera"

    case photo = "photo"

    case person = "person"
}

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }

    static func sfsymbol(_ systemName: SFSymbol) -> UIImage? {

        return UIImage(systemName: systemName.rawValue)
    }
}
