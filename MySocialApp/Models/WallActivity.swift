import Foundation

class WallActivity: Base {
    var action: ActivityType? {
        get { if let z = (super.getAttributeInstance("action") as! JSONableString?)?.string { return ActivityType(rawValue: z) } else { return nil } }
        set(action) { super.setStringAttribute(withName: "action", action?.rawValue) }
    }
    var object: Base? {
        get { return getQualifiedObject(super.getAttributeInstance("object")) as? Base }
        set(object) { super.setAttribute(withName: "object", object) }
    }
    var languageZone: LanguageZone? {
        get { if let z = (super.getAttributeInstance("language_zone") as! JSONableString?)?.string { return LanguageZone(rawValue: z) } else { return nil } }
        set(languageZone) { super.setStringAttribute(withName: "language_zone", languageZone?.rawValue) }
    }
    var actor: User? {
        get { return super.getAttributeInstance("actor") as? User }
        set(actor) { super.setAttribute(withName: "actor", actor) }
    }
    var target: JSONable? {
        get { return getQualifiedObject(super.getAttributeInstance("target")) }
        set(target) { super.setAttribute(withName: "target", target) }
    }
    var summary: String? {
        get { return (super.getAttributeInstance("summary") as! JSONableString?)?.string }
        set(summary) { super.setStringAttribute(withName: "summary", summary) }
    }
    var badge: Badge? {
        get { if let b = (super.getAttributeInstance("badge") as! JSONableString?)?.string { return Badge(rawValue: b) } else { return nil } }
    }
    
    enum Badge: String {
        case Pinned = "PINNED"
    }
    
    private func getQualifiedObject(_ from: JSONable?) -> JSONable? {
        if let from = from, let tt = from.getAttributeInstance("entity_type", withCreationMethod: JSONableString().initAttributes) as? JSONableString, let ttt = tt.string, let t = EntityType(rawValue: ttt) {
            var r = JSONable()
            switch t {
            case .TextWallMessage:
                r = TextWallMessage()
            case .Photo:
                r = Photo()
            case .Event:
                r = Event()
            case .Ride:
                r = Ride()
            case .Group:
                r = Group()
            case .Status:
                r = Status()
            case .User:
                r = User()
            default:
                break
            }
            r.cloneFrom(from)
            return r
        }
        return from
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "action", "languageZone", "summary", "badge":
            return JSONableString().initAttributes
        case "actor":
            return User().initAttributes
        case "object":
            return Base().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
