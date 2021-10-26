//
//  Date+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation

enum Format: String {

    // swiftlint:disable identifier_name
    case MM

    case dd
}

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }

    static var dateFormatter: DateFormatter {

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy.MM.dd HH:mm"

        return formatter

    }

    // get current time
    func getCurrentTime(format: Format) -> String {

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate(format.rawValue)
        return dateFormatter.string(from: date)
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
