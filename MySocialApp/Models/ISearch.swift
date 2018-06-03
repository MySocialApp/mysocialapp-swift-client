import Foundation

open class ISearch {
    
    var searchQuery: SearchQuery
    
    init(_ searchQuery: SearchQuery) {
        self.searchQuery = searchQuery
    }
    
    func toQueryParams() -> [String: String] {
        var m: [String: String] = [:]
        
        if let q = searchQuery.q {
            m["q"] = q
        }
        
        if let name = searchQuery.name {
            m["name"] = name
        }
        if let content = searchQuery.content {
            m["content"] = content
        }

        if let firstName = searchQuery.user?.firstName {
            m["first_name"] = firstName
        }
        if let lastName = searchQuery.user?.lastName {
            m["last_name"] = lastName
        }
        if let presentation = searchQuery.user?.presentation {
            m["content"] = presentation
        }
        if let gender = searchQuery.user?.gender {
            m["gender"] = gender.rawValue
        }
        if let location = searchQuery.user?.livingLocation {
            if let latitude = location.latitude {
                m["latitude"] = "\(latitude)"
            }
            if let longitude = location.longitude {
                m["longitude"] = "\(longitude)"
            }
        }

        if let distance = searchQuery.maximumDistanceInMeters {
            m["maximum_distance"] = "\(distance)"
        }
    
        if let dateField = searchQuery.dateField {
            m["date_field"] = dateField
        } else {
            m["date_field"] = "created_date"
        }
        if let date = searchQuery.startDate {
            m["start_date"] = DateUtils.toISO8601(date)
        }
        if let date = searchQuery.endDate {
            m["end_date"] = DateUtils.toISO8601(date)
        }

        if let order = searchQuery.sortOrder {
            m["sort_order"] = order.rawValue
        }

        return m
    }
}
