import Foundation

internal class ConnectionPool {
    internal var semaphore: DispatchSemaphore
    internal var timeout: TimeInterval
    
    internal init(_ size: Int, _ timeoutInMinutes: Double) {
        self.semaphore = DispatchSemaphore(value: size)
        self.timeout = TimeInterval(timeoutInMinutes * 60)
    }
}
