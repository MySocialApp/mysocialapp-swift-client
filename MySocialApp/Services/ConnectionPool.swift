import Foundation

internal class ConnectionPool {
    internal var maxConnections: Int
    internal var timeout: TimeInterval
    
    internal init(_ size: Int, _ timeoutInMinutes: Double) {
        self.maxConnections = size
        self.timeout = TimeInterval(timeoutInMinutes * 60)
    }
}
