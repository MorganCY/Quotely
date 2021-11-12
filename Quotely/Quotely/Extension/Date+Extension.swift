//
//  Date+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation

enum Format: String {

    // swiftlint:disable identifier_name
    case yyyy
    case MM
    case dd
}

extension Date {

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }

    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

    static var fullDateFormatter: DateFormatter {

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"

        return formatter
    }

    static var dateFormatter: DateFormatter {

        let formatter = DateFormatter()

        formatter.dateFormat = "dd"

        return formatter
    }

    static var monthFormatter: DateFormatter {

        let formatter = DateFormatter()

        formatter.dateFormat = "MM"

        return formatter
    }

    static var timeFormatter: DateFormatter {

        let formatter = DateFormatter()

        formatter.dateFormat = "h:mm a"

        return formatter
    }

    func getCurrentTime(format: Format) -> String {

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate(format.rawValue)
        return dateFormatter.string(from: date)
    }

    func timeAgoDisplay() -> String {

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension Date {

    static func getMonthAndYearBetween(
        from start: Date,
        to end: Date
    ) -> [String] {

        var allMonths: [String] = []

        guard start < end else { return allMonths }

        let calendar = Calendar.current

        let month = calendar.dateComponents([.month], from: start, to: end).month ?? 0

        for i in 0...month {

            if let date = calendar.date(byAdding: .month, value: i, to: start) {

                allMonths.append(Date.monthFormatter.string(from: date))
            }
        }
        return allMonths
    }
}
