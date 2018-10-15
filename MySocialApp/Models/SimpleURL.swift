import Foundation

public class SimpleURL: Base {
    public convenience init(_ url: String) {
        self.init()
        self.displayedName = url
    }
}

