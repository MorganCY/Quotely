import Foundation
import UIKit

enum BaseColor: String {

    // swiftlint:disable identifier_name
    case BG
    case M1, M2, M3, M4, A1
}

extension UIColor {

    static let BG = baseColor(.BG) ?? UIColor(red: 235 / 255, green: 231 / 255, blue: 227 / 255, alpha: 1)
    static let M1 = baseColor(.M1) ?? UIColor(red: 149 / 255, green: 147 / 255, blue: 116 / 255, alpha: 1)
    static let M2 = baseColor(.M2) ?? UIColor(red: 192 / 255, green: 191 / 255, blue: 171 / 255, alpha: 1)
    static let M3 = baseColor(.M3) ?? UIColor(red: 212 / 255, green: 213 / 255, blue: 199 / 255, alpha: 1)
    static let M4 = baseColor(.M4) ?? UIColor(red: 223 / 255, green: 223 / 255, blue: 213 / 255, alpha: 1)
    static let A1 = baseColor(.A1) ?? UIColor(red: 155 / 255, green: 137 / 255, blue: 114 / 255, alpha: 1)

    private static func baseColor(_ color: BaseColor) -> UIColor? {

        return UIColor(named: color.rawValue)
    }

    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }

    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0

        return String(format: "%06x", rgb)
    }
}
