import Foundation
import RxSwift

class FluentAccount {
    var session: Session
    
    public init(_ session:  Session) {
        self.session = session
    }
    
    public func blockingGet() throws -> User? {
        return try self.get().toBlocking().first()
    }
    
    public func get() -> Observable<User> {
        return self.session.clientService.account.get()
    }

    /**
     * Caution: your account will be completely erased and no more available.
     * This method delete all your data that belongs to this account.!!
     */
    func blockingRequestForDeleteAccount(password: String) throws -> Bool? {
        return try requestForDeleteAccount(password: password).toBlocking().first()
    }
    
    /**
     * Caution: your account will be completely erased and no more available.
     * This method delete all your data that belongs to this account.!!
     */
    func requestForDeleteAccount(password: String) -> Observable<Bool> {
        return session.clientService.login.deleteAccount(Login(username: "", password: password))
    }
}
