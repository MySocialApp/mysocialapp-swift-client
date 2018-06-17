import Foundation
import RxSwift

public struct ClientConfiguration {
    var readTimeoutInMilliseconds: Int64 = 10000
    var writeTimeoutInMilliseconds: Int64 = 10000
    internal lazy var scheduler: OperationQueueScheduler = self.createScheduler()
    var connectionPool: ConnectionPool = ConnectionPool(5, 5)
    var headersToInclude: [String:String]? = nil
    var debug: Bool = false

    private func createScheduler() -> OperationQueueScheduler {
        let o = OperationQueue()
        o.maxConcurrentOperationCount = self.connectionPool.maxConnections
        o.name = "MySocialApp"
        o.qualityOfService = QualityOfService.background
        return OperationQueueScheduler(operationQueue: o)
    }
}
