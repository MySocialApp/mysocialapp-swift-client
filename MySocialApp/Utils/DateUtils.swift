//
//  DateUtils.swift
//  MySocialApp
//
//  Created by Aurelien Bocquet on 13/05/2018.
//  Copyright © 2018 4Tech. All rights reserved.
//

import Foundation

internal struct DateUtils {
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "UTC")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            return formatter
        }()
        static let iso8601ms: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "UTC")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            return formatter
        }()
    }
    
    static func toISO8601(_ d: Date) -> String {
        return Formatter.iso8601.string(from: d)
    }
    
    static func fromISO8601(_ s: String) -> Date? {
        return Formatter.iso8601.date(from: s)
    }
    
    static func fromISO8601ms(_ s: String) -> Date? {
        return Formatter.iso8601ms.date(from: s)
    }
    
}
