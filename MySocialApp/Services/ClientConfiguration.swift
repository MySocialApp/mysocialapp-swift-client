import Foundation
import RxSwift

public struct ClientConfiguration {
    var readTimeoutInMilliseconds: Int64 = 10000
    var writeTimeoutInMilliseconds: Int64 = 10000
    var connectionPool: ConnectionPool = ConnectionPool(5, 5)
    internal lazy var scheduler = self.connectionPool.createScheduler()
    var headersToInclude: [String:String]? = nil
    var debug: Bool = false
}
