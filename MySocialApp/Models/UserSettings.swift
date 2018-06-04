import Foundation

public enum LanguageZone: String {
    case fr = "FR"
    case en = "EN"
    case de = "DE"
}

public enum InterfaceLanguage: String {
    case fr = "FR"
    case en = "EN"
    case de = "DE"
    static let all = [en,fr,de]
    static var systemLanguage: InterfaceLanguage {
        get {
            for l in all {
                if Locale.current.identifier.lowercased().contains(l.rawValue.lowercased()) {
                    return l
                }
            }
            return en
        }
    }
}

public enum MailFrequency: String {
    case never = "NEVER"
    case realTime = "REAL_TIME"
    case daily = "DAILY"
    case weekly = "WEEKLY"
}

public class NotificationSettings: JSONable {
    public var enabled: Bool? {
        get { return (super.getAttributeInstance("enabled") as! JSONableBool?)?.bool }
        set(enabled) { super.setBoolAttribute(withName: "enabled", enabled) }
    }
    public var pushEnabled: Bool? {
        get { return (super.getAttributeInstance("push_enabled") as! JSONableBool?)?.bool }
        set(pushEnabled) { super.setBoolAttribute(withName: "push_enabled", pushEnabled) }
    }
    public var mailEnabled: Bool? {
        get { return (super.getAttributeInstance("mail_enabled") as! JSONableBool?)?.bool }
        set(mailEnabled) { super.setBoolAttribute(withName: "mail_enabled", mailEnabled) }
    }
    public var mailFrequency: MailFrequency? {
        get { if let z = (super.getAttributeInstance("mail_frequency") as! JSONableString?)?.string { return MailFrequency(rawValue: z) } else { return .realTime } }
        set(mailFrequency) { super.setStringAttribute(withName: "mail_frequency", mailFrequency?.rawValue) }
    }
    public var eventEnabled: Bool? {
        get { return (super.getAttributeInstance("event_enabled") as! JSONableBool?)?.bool }
        set(eventEnabled) { super.setBoolAttribute(withName: "event_enabled", eventEnabled) }
    }
    public var maximumDistance: Int? {
        get { return (super.getAttributeInstance("maximum_distance") as! JSONableInt?)?.int }
        set(maximumDistance) { super.setIntAttribute(withName: "maximum_distance", maximumDistance) }
    }
    public var mentionEnabled: Bool? {
        get { return (super.getAttributeInstance("mention_enabled") as! JSONableBool?)?.bool }
        set(mentionEnabled) { super.setBoolAttribute(withName: "mention_enabled", mentionEnabled) }
    }
    public var messagingEnabled: Bool? {
        get { return (super.getAttributeInstance("messaging_enabled") as! JSONableBool?)?.bool }
        set(messagingEnabled) { super.setBoolAttribute(withName: "messaging_enabled", messagingEnabled) }
    }
    public var commentEnabled: Bool? {
        get { return (super.getAttributeInstance("comment_enabled") as! JSONableBool?)?.bool }
        set(commentEnabled) { super.setBoolAttribute(withName: "comment_enabled", commentEnabled) }
    }
    public var likeEnabled: Bool? {
        get { return (super.getAttributeInstance("like_enabled") as! JSONableBool?)?.bool }
        set(likeEnabled) { super.setBoolAttribute(withName: "like_enabled", likeEnabled) }
    }
    public var offerEnabled: Bool? {
        get { return (super.getAttributeInstance("offer_enabled") as! JSONableBool?)?.bool }
        set(offerEnabled) { super.setBoolAttribute(withName: "offer_enabled", offerEnabled) }
    }
    public var soundEnabled: Bool? {
        get { return (super.getAttributeInstance("sound_enabled") as! JSONableBool?)?.bool }
        set(soundEnabled) { super.setBoolAttribute(withName: "sound_enabled", soundEnabled) }
    }
    public var newsletterEnabled: Bool? {
        get { return (super.getAttributeInstance("newsletter_enabled") as! JSONableBool?)?.bool }
        set(newsletterEnabled) { super.setBoolAttribute(withName: "newsletter_enabled", newsletterEnabled) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "enabled", "push_enabled", "mail_enabled", "event_enabled", "mention_enabled", "messaging_enabled", "comment_enabled", "like_enabled", "offer_enabled", "sound_enabled", "newsletter_enabled":
            return JSONableBool().initAttributes
        case "maximum_distance":
            return JSONableInt().initAttributes
        case "mail_frequency":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}

public class UserSettings: JSONable {
    public var statStatusEnabled: Bool? {
        get { return (super.getAttributeInstance("stat_status_enabled") as! JSONableBool?)?.bool }
        set(statStatusEnabled) { super.setBoolAttribute(withName: "stat_status_enabled", statStatusEnabled) }
    }
    public var notification: NotificationSettings? {
        get { return super.getAttributeInstance("notification") as? NotificationSettings }
        set(notification) { super.setAttribute(withName: "notification", notification) }
    }
    public var languageZone: LanguageZone? {
        get { if let z = (super.getAttributeInstance("language_zone") as! JSONableString?)?.string { return LanguageZone(rawValue: z) } else { return .fr } }
        set(languageZone) { super.setStringAttribute(withName: "language_zone", languageZone?.rawValue) }
    }
    public var interfaceLanguage: InterfaceLanguage? {
        get { if let z = (super.getAttributeInstance("interface_language") as! JSONableString?)?.string { return InterfaceLanguage(rawValue: z) } else { return .fr } }
        set(interfaceLanguage) { super.setStringAttribute(withName: "interface_language", interfaceLanguage?.rawValue) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "stat_status_enabled":
            return JSONableBool().initAttributes
        case "notification":
            return NotificationSettings().initAttributes
        case "language_zone", "interface_language":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
