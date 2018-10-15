import Foundation
import RxSwift

public class PreviewNotification: Base {
    public var total: Int?{
        get { return (super.getAttributeInstance("total") as! JSONableInt?)?.int }
        set(total) { super.setIntAttribute(withName: "total", total) }
    }
    public var lastNotification: Notification?{
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

    public func blockingConsume() throws -> PreviewNotification? {
        return try consume().toBlocking().first()
    }
    
    public func consume() -> Observable<PreviewNotification> {
        if let s = session, let id = self.id {
            return s.clientService.notification.consume(id)
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
}
