//
//  UIImage+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

enum ImageAsset: String {

    case logo
    case logoWithText
    case testProfile = "test_profile"
    case like
    case dislike
    case bg1
    case bg2
    case bg3
    case bg4
    case instagram
    case back
}

enum SFSymbol: String {

    // Tab Bar
    case writeNormal = "pencil.circle"
    case writeSelected = "pencil.circle.fill"
    case lightbulbNormal = "lightbulb"
    case lightbulbSelected = "lightbulb.fill"
    case personNormal = "person"
    case personSelected = "person.fill"
    case quoteNormal = "quote.bubble"
    case quoteSelected = "quote.bubble.fill"

    // Journal
    case smile = "face.smiling"
    case book = "book"
    case umbrella = "umbrella"
    case moon = "moon"
    case fire = "flame"
    case music = "music.note"
    case calendar = "calendar"
    case collapse = "arrow.up.circle"

    // Swipe Card
    case reset = "arrow.clockwise"
    case bookmarkNormal = "bookmark"
    case bookmarkSlashed = "bookmark.slash"
    case shareNormal = "square.and.arrow.up"
    case heartNormal = "heart"
    case heartSelected = "heart.fill"
    case download = "icloud.and.arrow.down"

    // Add Post
    case addPost = "plus.square"
    case writeCardPost = "square.and.pencil"
    case camera = "camera"
    case photo = "photo"
    case fileScanner = "doc.text.viewfinder"

    // Post Action
    case comment = "text.bubble"
    case send = "paperplane.fill"
    case delete = "trash"

    // General
    case closeButton = "xmark.circle.fill"
    case settings = "gearshape"
    case next = "chevron.right"
    case report = "exclamationmark.bubble"
}

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage {

        return UIImage(named: asset.rawValue) ?? UIImage()
    }

    static func sfsymbol(_ systemName: SFSymbol) -> UIImage {

        return UIImage(systemName: systemName.rawValue) ?? UIImage()
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
