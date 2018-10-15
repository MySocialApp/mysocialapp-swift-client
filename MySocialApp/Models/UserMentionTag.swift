import Foundation

public class UserMentionTag: TagEntity {
    public var mentionedUser: User?{
        get { return super.getAttributeInstance("mentioned_user") as? User }
        set(mentionedUser) { super.setAttribute(withName: "mentioned_user", mentionedUser) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "mentioned_user":
            return User().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
