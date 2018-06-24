import Foundation
import RxSwift

class RestCustomField: RestBase<CustomField, CustomField> {
    
    private var customFieldsByType: [String:[CustomField]] = [:]
    
    func list(for: BaseCustomField) -> Observable<JSONableArray<CustomField>> {
        switch `for` {
            case is User:
                return self.listFor("User","/account/customfield")
            case is Event:
                return self.listFor("Event","/event/customfield")
            case is Group:
                return self.listFor("Group","/group/customfield")
            case is Ride:
                return self.listFor("Ride","/ride/customfield")
            case is PointOfInterest:
                return self.listFor("PointOfInterest","/poi/customfield")
            default:
                return super.listEmpty()
        }
    }
    
    private func listFor(_ name: String, _ url: String) -> Observable<JSONableArray<CustomField>> {
        if let cf = self.customFieldsByType[name] {
            return Observable.create {
                obs in
                let a = JSONableArray<CustomField>()
                a.array = cf
                obs.onNext(a)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        } else {
            return super.list(url).map {
                self.customFieldsByType[name] = $0.array
                return $0
            }
        }
    }
}

