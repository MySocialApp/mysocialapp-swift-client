import Foundation

public protocol Taggable {
    var firstURLTagEntityAvailable: URLTag? {get}
    var tagEntities: TagEntities? {get set}
}

extension Taggable {
    public var firstURLTagEntityAvailable: URLTag? {
        get {
            return tagEntities?.urlTags?.first
        }
    }
}
