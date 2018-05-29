import Foundation

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
}
