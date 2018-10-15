import Foundation

public class AccountEvent: JSONable {
    public var conversation: [String:Double]? {
        get {
            if let m = super.getAttributeInstance("conversation") as? JSONableMap<JSONableDouble> {
                return m.getAttributes { ($0 as? JSONableDouble)?.double }
            } else {
                return nil
            }
        }
    }
    public var notification: [String:Double]? {
        get {
            if let m = super.getAttributeInstance("notification") as? JSONableMap<JSONableDouble> {
                return m.getAttributes { ($0 as? JSONableDouble)?.double }
            } else {
                return nil
            }
        }
    }
    public var friendRequest: [String:Double]? {
        get {
            if let m = super.getAttributeInstance("friend_request") as? JSONableMap<JSONableDouble> {
                return m.getAttributes { ($0 as? JSONableDouble)?.double }
            } else {
                return nil
            }
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
        if let c = self.conversation?["total_unreads"] {
            return Int(c)
        }
        return 0
    }
    
    public func getUnreadNotifications() -> Int {
        if let n = self.notification?["total_unreads"] {
            return Int(n)
        }
        return 0
    }
    
    public func getIncomingFriendRequests() -> Int {
        if let f = self.friendRequest?["total_incoming_requests"] {
            return Int(f)
        }
        return 0
    }
}
