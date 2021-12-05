import Foundation
import UIKit

enum BaseColor: String {

    // swiftlint:disable identifier_name
    case BG
    case M1, M2, M3, M4, A1, S1
}

extension UIColor {

    static let BG = baseColor(.BG) ?? UIColor(red: 235 / 255, green: 231 / 255, blue: 227 / 255, alpha: 1)
    static let M1 = baseColor(.M1) ?? UIColor(red: 149 / 255, green: 147 / 255, blue: 116 / 255, alpha: 1)
    static let M2 = baseColor(.M2) ?? UIColor(red: 192 / 255, green: 191 / 255, blue: 171 / 255, alpha: 1)
    static let M3 = baseColor(.M3) ?? UIColor(red: 212 / 255, green: 213 / 255, blue: 199 / 255, alpha: 1)
    static let M4 = baseColor(.M4) ?? UIColor(red: 223 / 255, green: 223 / 255, blue: 213 / 255, alpha: 1)
    static let A1 = baseColor(.A1) ?? UIColor(red: 155 / 255, green: 137 / 255, blue: 114 / 255, alpha: 1)
    static let S1 = baseColor(.S1) ?? UIColor(red: 80 / 255, green: 79 / 255, blue: 63 / 255, alpha: 1)

    private static func baseColor(_ color: BaseColor) -> UIColor? {

        return UIColor(named: color.rawValue)
    }
}
