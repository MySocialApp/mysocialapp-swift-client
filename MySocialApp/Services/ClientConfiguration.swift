import Foundation
import RxSwift


public class ClientConfiguration {
    var readTimeoutInMilliseconds: Int64
    var writeTimeoutInMilliseconds: Int64
    var connectionPool: ConnectionPool
    internal lazy var scheduler = self.connectionPool.createScheduler()
    var headersToInclude: [String:String]?
    var debug: Bool
    
    internal init(readTimeoutInMilliseconds: Int64 = 10000, writeTimeoutInMilliseconds: Int64 = 10000, connectionPool: ConnectionPool = ConnectionPool(5, 5), headersToInclude: [String:String]? = nil, debug: Bool = false) {
        self.readTimeoutInMilliseconds = readTimeoutInMilliseconds
        self.writeTimeoutInMilliseconds = writeTimeoutInMilliseconds
        self.connectionPool = connectionPool
        self.headersToInclude = headersToInclude
        self.debug = debug
    }
}
