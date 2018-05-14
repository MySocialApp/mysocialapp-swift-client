import Foundation

class Reset: Base {
    
    var login: String?{
        get { return (super.getAttributeInstance("login") as! JSONableString?)?.string }
        set(login) { super.setStringAttribute(withName: "login", login) }
    }
    var response: String?{
        get { return (super.getAttributeInstance("response") as! JSONableString?)?.string }
        set(response) { super.setStringAttribute(withName: "response", response) }
    }
    
    public override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "login", "response":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public required init() {
        super.init()
    }
    
    init(login: String) {
        super.init()
        self.login = login
    }
    
}
