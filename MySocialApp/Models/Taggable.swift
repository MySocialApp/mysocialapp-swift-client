import Foundation

protocol Taggable {
    var firstURLTagEntityAvailable: URLTag? {get}
    var tagEntities: TagEntities? {get set}
}

extension Taggable {
    var firstURLTagEntityAvailable: URLTag? {
        get {
            return tagEntities?.urlTags?.first
        }
    }
}
