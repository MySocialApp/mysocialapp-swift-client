import Foundation

class SimpleURL: Base {
    convenience init(_ url: String) {
        self.init()
        self.displayedName = url
    }
}

