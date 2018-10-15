import Foundation

struct SearchQuery {
    var user: User? = nil
    var q: String? = nil
    var name: String? = nil
    var content: String? = nil
    var maximumDistanceInMeters: Double? = nil
    var sortOrder: SortOrder? = nil
    var startDate: Date? = nil
    var endDate: Date? = nil
    var dateField: String? = nil
    var matchAll: Bool? = nil
    var startsWith: Bool? = nil
    var endsWith: Bool? = nil
}

public enum SortOrder: String {
    case asc = "ASC"
    case desc = "DESC"
}
