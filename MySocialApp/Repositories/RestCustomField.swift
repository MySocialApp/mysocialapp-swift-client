import Foundation
import RxSwift

class RestCustomField: RestBase<CustomField, CustomField> {
    
    func list(for: BaseCustomField) -> Observable<JSONableArray<CustomField>> {
        if `for` is Event {
            return super.list("/event/customfield")
        } else if `for` is Group {
            return super.list("/group/customfield")
        } else if `for` is Ride {
            return super.list("/ride/customfield")
        } else if `for` is PointOfInterest {
            return super.list("/poi/customfield")
        }
        return super.listEmpty()
    }
}

