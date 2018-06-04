import Foundation
import RxSwift

public class SearchResult: JSONable {
    
    public var matchedCount: Int64? {
        get { return (super.getAttributeInstance("matched_count") as! JSONableInt64?)?.int64 }
        set(matchedCount) { super.setInt64Attribute(withName: "matched_count", matchedCount) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "matched_count":
            return JSONableInt64().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
