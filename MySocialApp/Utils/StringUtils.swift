//
//  StringUtils.swift
//  MySocialApp
//
//  Created by Aurelien Bocquet on 13/05/2018.
//  Copyright © 2018 4Tech. All rights reserved.
//

import Foundation

internal struct StringUtils {

    static func trimToNil(_ s: String?) -> String? {
        guard let s = s else {
            return nil
        }
        let trimmed = s.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmed.count == 0 {
            return nil
        }
        return trimmed
    }
    
    static func toSafeURL(_ s: String) -> String {
        if s.hasPrefix("http://") {
            return s.replacingOccurrences(of: "http://", with: "https://")
        } else {
            return s
        }
    }
    
    static func from(data: Data) -> String {
        return data.map { String(format: "%02x", $0) }.joined()
    }
    
    static func safeTrim(_ s: String?) -> String {
        if let s = s, let trimmed = trimToNil(s) {
            return trimmed
        } else {
            return ""
        }
    }
}
