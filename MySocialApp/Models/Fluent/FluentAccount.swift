import Foundation
import RxSwift

class FluentAccount {
    var session: Session
    
    public init(_ session:  Session) {
        self.session = session
    }
    
    public func blockingGet() throws -> User? {
        return try self.get().toBlocking().last()
    }
    
    public func get() -> Observable<User> {
        return self.session.clientService.account.get()
    }
}
