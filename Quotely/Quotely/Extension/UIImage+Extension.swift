//
//  UIImage+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import UIKit

enum ImageAsset: String {

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
    case write = "highlighter"
    case cardsNormal = "square.stack"
    case cardsSelected = "square.stack.fill"
    case lightbulbNormal = "lightbulb"
    case lightbulbSelected = "lightbulb.fill"
    case personNormal = "person"
    case personSelected = "person.fill"

    // Journal
    case calendar = "calendar"
    case smile = "face.smiling"
    case book = "book"
    case umbrella = "umbrella"
    case moon = "moon"
    case fire = "flame"
    case music = "music.note"
    case color = "paintpalette"
    case collapse = "arrow.up.circle"

    case writeCardPost = "square.and.pencil"
    case reset = "arrow.clockwise"
    case shareNormal = "square.and.arrow.up"
    case cameraNormal = "camera"
    case photo = "photo"
    case heartNormal = "heart"
    case heartSelected = "heart.fill"
    case send = "paperplane.fill"
    case closeButton = "xmark.circle.fill"
    case comment = "text.bubble"
    case textScanner = "text.viewfinder"
    case fileScanner = "doc.text.viewfinder"
    case addPost = "plus.square"
    case delete = "trash"
    case dislike = "heart.slash"
    case cards = "bookmark.fill"
    case quoteNormal = "quote.bubble"
    case quoteSelected = "quote.bubble.fill"
    case download = "icloud.and.arrow.down"
    case settings = "gearshape"
    case next = "chevron.right"
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
