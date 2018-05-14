import Foundation

enum ActivityType: String {
    case Publish = "PUBLISH"
    case Edit = "EDIT"
    case Delete = "DELETE"
    case Like = "LIKE"
    case Dislike = "DISLIKE"
    case Join = "JOIN"
    case Leave = "LEAVE"
    case Mention = "MENTION"
    case Add = "ADD"
    case Remove = "REMOVE"
}
