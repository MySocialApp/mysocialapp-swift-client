import Foundation
import RxSwift

class PreviewNotification: Base {
    var total: Int?{
        get { return (super.getAttributeInstance("total") as! JSONableInt?)?.int }
        set(total) { super.setIntAttribute(withName: "total", total) }
    }
    var lastNotification: Notification?{
        get { return super.getAttributeInstance("last_notification") as? Notification }
        set(lastNotification) { super.setAttribute(withName: "last_notification", lastNotification) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "total":
            return JSONableInt().initAttributes
        case "last_notification":
            return Notification().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }

    func blockingConsume() throws -> PreviewNotification? {
        return try consume().toBlocking().first()
    }
    
    func consume() -> Observable<PreviewNotification> {
        if let s = session, let id = self.id {
            return s.clientService.notification.consume(id)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
}
