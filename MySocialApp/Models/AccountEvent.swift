import Foundation

class AccountEvent: JSONable {
    var conversation: JSONableMap<JSONableDouble>? {
        get {
            return super.getAttributeInstance("conversation") as? JSONableMap<JSONableDouble>
        }
    }
    var notification: JSONableMap<JSONableDouble>? {
        get {
            return super.getAttributeInstance("notification") as? JSONableMap<JSONableDouble>
        }
    }
    var friendRequest: JSONableMap<JSONableDouble>? {
        get {
            return super.getAttributeInstance("friend_request") as? JSONableMap<JSONableDouble>
        }
    }

    internal override func getAttributeCreationMethod(name: String) -> JSONable.CreationMethod {
        switch(name) {
        case "conversation", "notification", "friend_request":
            return JSONableMap<JSONableDouble>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public func getUnreadConversations() -> Int {
        if let c = self.conversation, let u = c.getValue(forKey: "total_unreads")?.double {
            return Int(u)
        }
        return 0
    }
    
    public func getUnreadNotifications() -> Int {
        if let n = self.notification, let u = n.getValue(forKey: "total_unreads")?.double {
            return Int(u)
        }
        return 0
    }
    
    public func getIncomingFriendRequests() -> Int {
        if let f = self.friendRequest, let u = f.getValue(forKey: "total_incoming_requests")?.double {
            return Int(u)
        }
        return 0
    }
}
