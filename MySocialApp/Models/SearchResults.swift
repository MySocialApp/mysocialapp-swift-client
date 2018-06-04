import Foundation
import RxSwift

public class SearchResults: JSONable {
    
    public typealias SearchType = String
    
    public var matchedCount: Int64? {
        get { return (super.getAttributeInstance("matched_count") as! JSONableInt64?)?.int64 }
        set(matchedCount) { super.setInt64Attribute(withName: "matched_count", matchedCount) }
    }
    public var queryId: String? {
        get { return (super.getAttributeInstance("query_id") as! JSONableString?)?.string }
        set(queryId) { super.setStringAttribute(withName: "query_id", queryId) }
    }
    public var page: Int? {
        get { return (super.getAttributeInstance("page") as! JSONableInt?)?.int }
        set(page) { super.setIntAttribute(withName: "page", page) }
    }
    public var size: Int? {
        get { return (super.getAttributeInstance("size") as! JSONableInt?)?.int }
        set(size) { super.setIntAttribute(withName: "size", size) }
    }
    public var matchedTypes: [SearchType]? {
        get { return (super.getAttributeInstance("matched_types") as! JSONableArray<JSONableString>?)?.array.flatMap { $0.string } }
        set(matchedTypes) { super.setArrayAttribute(withName: "matched_types", matchedTypes?.flatMap { JSONableString($0) }) }
    }
    public var resultsByType: SearchResultTypes? {
        get { return super.getAttributeInstance("results_by_type") as? SearchResultTypes }
        set(resultsByType) { super.setAttribute(withName: "results_by_type", resultsByType) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "matched_count":
            return JSONableInt64().initAttributes
        case "query_id":
            return JSONableString().initAttributes
        case "page", "size":
            return JSONableInt().initAttributes
        case "matched_types":
            return JSONableArray<JSONableString>().initAttributes
        case "results_by_type":
            return SearchResultTypes().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
