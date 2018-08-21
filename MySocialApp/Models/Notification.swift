import Foundation
import RxSwift

public class Notification: Base {
    public var title: String? {
        get { return (super.getAttributeInstance("title") as! JSONableString?)?.string }
        set(title) { super.setStringAttribute(withName: "title", title) }
    }
    public var url: String? {
        get { return (super.getAttributeInstance("url") as! JSONableString?)?.string }
        set(url) { super.setStringAttribute(withName: "url", url) }
    }
    public var desc: String? {
        get { return (super.getAttributeInstance("description") as! JSONableString?)?.string }
        set(desc) { super.setStringAttribute(withName: "description", desc) }
    }
    public var imageURL: String? {
        get { return (super.getAttributeInstance("image_url") as! JSONableString?)?.string }
        set(imageURL) { super.setStringAttribute(withName: "image_url", imageURL) }
    }
    public var notificationKey: String? {
        get { return (super.getAttributeInstance("notification_key") as! JSONableString?)?.string }
        set(notificationKey) { super.setStringAttribute(withName: "notification_key", notificationKey) }
    }
    public var requestAck: Bool? {
        get { return (super.getAttributeInstance("request_ack") as! JSONableBool?)?.bool }
        set(requestAck) { super.setBoolAttribute(withName: "request_ack", requestAck) }
    }
    public var showNotification: Bool? {
        get { return (super.getAttributeInstance("show_notification") as! JSONableBool?)?.bool }
        set(showNotification) { super.setBoolAttribute(withName: "show_notification", showNotification) }
    }
    public var forceNotificationSound: Bool? {
        get { return (super.getAttributeInstance("force_notification_sound") as! JSONableBool?)?.bool }
        set(forceNotificationSound) { super.setBoolAttribute(withName: "force_notification_sound", forceNotificationSound) }
    }
    public var payload: Base? {
        get { return super.getAttributeInstance("payload") as? Base }
        set(payload) { super.setAttribute(withName: "payload", payload) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "title", "url", "image_url", "notification_key", "description":
            return JSONableString().initAttributes
        case "request_ack", "show_notification", "force_notification_sound":
            return JSONableBool().initAttributes
        case "payload":
            return Base().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public func blockingAck(_ notificationAck: NotificationAck) throws -> NotificationAck? {
        return try self.ack(notificationAck).toBlocking().first()
    }
    
    public func ack(_ notificationAck: NotificationAck) -> Observable<NotificationAck> {
        if notificationAck.notificationKey == nil {
            notificationAck.notificationKey = self.notificationKey
        }
        return self.session?.clientService.notificationAck.post(notificationAck) ?? Observable.empty()
    }
}
