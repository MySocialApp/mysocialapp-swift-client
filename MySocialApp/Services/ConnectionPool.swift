import Foundation
import RxSwift

internal class ConnectionPool {
    internal var maxConnections: Int
    internal var timeout: TimeInterval
    
    internal init(_ size: Int, _ timeoutInMinutes: Double) {
        self.maxConnections = size
        self.timeout = TimeInterval(timeoutInMinutes * 60)
    }
    
    internal func createScheduler() -> OperationQueueScheduler {
        let o = OperationQueue()
        o.maxConcurrentOperationCount = self.maxConnections
        o.name = "MySocialApp"
        o.qualityOfService = QualityOfService.background
        return OperationQueueScheduler(operationQueue: o)
    }
}
