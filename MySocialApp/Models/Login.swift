import Foundation

public class Login: Base {

    public var username: String? {
        get { return (super.getAttributeInstance("username") as! JSONableString?)?.string }
        set(username) { super.setStringAttribute(withName: "username", username) }
    }

    public var password: String? {
        get { return (super.getAttributeInstance("password") as! JSONableString?)?.string }
        set(password) { super.setStringAttribute(withName: "password", password) }
    }

    public var accessToken: String? {
        get { return (super.getAttributeInstance("access_token") as! JSONableString?)?.string }
        set(accessToken) { super.setStringAttribute(withName: "access_token", accessToken) }
    }

    public required init() {
        super.init()
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "username", "password", "access_token":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public init(username: String, password: String) {
        super.init()
        self.username = username
        self.password = password
    }
    
    public init(accessToken: String) {
        super.init()
        self.accessToken = accessToken
    }
}
