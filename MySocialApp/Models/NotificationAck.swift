import Foundation

public class NotificationAck: JSONable {
    public var deviceId: String? {
        get { return (super.getAttributeInstance("device_id") as! JSONableString?)?.string }
        set(deviceId) { super.setStringAttribute(withName: "device_id", deviceId) }
    }
    public var advertisingId: String? {
        get { return (super.getAttributeInstance("advertising_id") as! JSONableString?)?.string }
        set(advertisingId) { super.setStringAttribute(withName: "advertising_id", advertisingId) }
    }
    public var notificationKey: String? {
        get { return (super.getAttributeInstance("notification_key") as! JSONableString?)?.string }
        set(notificationKey) { super.setStringAttribute(withName: "notification_key", notificationKey) }
    }
    public var notificationAction: Action? {
        get { if let s = (super.getAttributeInstance("notification_action") as! JSONableString?)?.string { return Action(rawValue: s) } else { return nil } }
        set(notificationAction) { super.setStringAttribute(withName: "notification_action", notificationAction?.rawValue) }
    }
    public var location: BaseLocation? {
        get { return super.getAttributeInstance("location") as? BaseLocation }
        set(location) { super.setAttribute(withName: "location", location) }
    }
    public var appPlatform: String? {
        get { return (super.getAttributeInstance("app_platform") as! JSONableString?)?.string }
        set(appPlatform) { super.setStringAttribute(withName: "app_platform", appPlatform) }
    }
    public var appVersion: String? {
        get { return (super.getAttributeInstance("app_version") as! JSONableString?)?.string }
        set(appVersion) { super.setStringAttribute(withName: "app_version", appVersion) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "device_id", "advertising_id", "notification_key", "notification_action", "app_platform", "app_version":
            return JSONableString().initAttributes
        case "location":
            return BaseLocation().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public enum Action: String {
        case Received = "RECEIVED"
        case Read = "READ"
        case Opened = "OPENED"
    }

    public enum AppPlatform: String {
        case IOS = "IOS"
        case SDK = "SDK"
    }
    
    public class Builder {
        private var mDeviceId: String? = nil
        private var mAppPlatform: AppPlatform? = nil
        private var mAppVersion: String? = nil
        private var mAdvertisingId: String? = nil
        private var mNotificationKey: String? = nil
        private var mNotificationAction: String? = nil
        private var mLocation: Location? = nil
        
        public init() {}
        
        public func setDeviceId(_ deviceId: String) -> Builder {
            self.mDeviceId = deviceId
            return self
        }
        
        public func setAppPlatform(_ appPlatform: AppPlatform) -> Builder {
            self.mAppPlatform = appPlatform
            return self
        }
        
        public func setAppVersion(_ appVersion: String) -> Builder {
            self.mAppVersion = appVersion
            return self
        }
        
        public func setAdvertisingId(_ advertisingId: String) -> Builder {
            self.mAdvertisingId = advertisingId
            return self
        }
        
        public func setNotificationKey(_ notificationKey: String) -> Builder {
            self.mNotificationKey = notificationKey
            return self
        }
        
        public func setNotificationAction(_ notificationAction: String) -> Builder {
            self.mNotificationAction = notificationAction
            return self
        }
        
        public func setLocation(_ location: Location) -> Builder {
            self.mLocation = location
            return self
        }
        
        public func build() -> NotificationAck {
            let n = NotificationAck()
            n.deviceId = mDeviceId
            n.appPlatform = mAppPlatform?.rawValue
            n.appVersion = mAppVersion
            n.advertisingId = mAdvertisingId
            n.notificationKey = mNotificationKey
            n.notificationAction = Action(rawValue: StringUtils.safeTrim(mNotificationAction))
            n.location = mLocation
            
            return n
        }
    }
    
}
