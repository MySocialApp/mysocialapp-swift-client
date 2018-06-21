import Foundation
import RxSwift

extension OperationQueueScheduler {
    internal convenience init(_ clientConfiguration: ClientConfiguration) {
        let o = OperationQueue()
        o.maxConcurrentOperationCount = clientConfiguration.connectionPool.maxConnections
        o.name = "MySocialApp"
        o.qualityOfService = QualityOfService.background
        self.init(operationQueue: o)
    }
}
