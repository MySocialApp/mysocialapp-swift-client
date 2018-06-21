import Foundation
import RxSwift

class RestCustomField: RestBase<CustomField, CustomField> {
    
    func list(for: BaseCustomField) -> Observable<JSONableArray<CustomField>> {
        switch `for` {
            case is User:
                return super.list("/account/customfield")
            case is Event:
                return super.list("/event/customfield")
            case is Group:
                return super.list("/group/customfield")
            case is Ride:
                return super.list("/ride/customfield")
            case is PointOfInterest:
                return super.list("/poi/customfield")
            default:
                return super.listEmpty()
        }
    }
}

