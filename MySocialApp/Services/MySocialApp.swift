import Foundation
import RxSwift
import RxBlocking

public class MySocialApp {
    
    private var configuration: Configuration
    private var clientConfiguration: ClientConfiguration
    private lazy var login = RestLogin(nil)
    private lazy var reset = RestReset(nil)
    private lazy var account = RestAccount(nil)
    
    internal init(_ builder: Builder) {
        self.configuration = Configuration(appId: builder.mAppId, apiEndpointURL: builder.mAPIEndpointURL)
        self.clientConfiguration = builder.mClientConfiguration
    }
    
    public class Builder {
        internal var mAppId: String = ""
        internal var mAPIEndpointURL: String? = nil
        internal var mClientConfiguration: ClientConfiguration = ClientConfiguration()
        
        public init() {}
        
        public func setAppId(_ appId: String) -> Builder {
            self.mAppId = appId
            return self
        }
        
        public func setAPIEndpointURL(_ appURL: String) -> Builder {
            self.mAPIEndpointURL = appURL
            return self
        }
        
        public func setClientConfiguration(_ clientConfiguration: ClientConfiguration) -> Builder {
            self.mClientConfiguration = clientConfiguration
            return self
        }
        
        public func build() -> MySocialApp {
            return MySocialApp(self)
        }
    }

    public func blockingCreateAccount(username: String, email: String, password: String, firstName: String? = nil) throws -> Session? {
        return try createAccount(username: username, email: email, password: password, firstName: firstName).toBlocking().first()
    }
    
    public func createAccount(username: String, email: String, password: String, firstName: String? = nil) -> Observable<Session> {
        let user = User()
        user.username = username
        if let n = firstName {
            user.firstName = n
        } else {
            user.firstName = username
        }
        user.email = email
        user.password = password
        return Observable.create {
            obs in
            let _ = self.account.create(user).subscribe {
                e in
                if let _ = e.element {
                    let _ = self.connect(username: username, password: password).subscribe {
                        e in
                        if let e = e.element {
                            obs.onNext(e)
                        } else {
                            obs.onCompleted()
                        }
                    }
                } else {
                    obs.onCompleted()
                }
            }
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    public func blockingConnectByEmail(email: String, password: String) throws -> Session? {
        return try self.connectByEmail(email: email, password: password).toBlocking().first()
    }
    
    public func connectByEmail(email: String, password: String) -> Observable<Session> {
        return self.connect(username: email, password: password)
    }
    
    public func blockingConnect(username: String, password: String) throws -> Session? {
        return try self.connect(username: username, password: password).toBlocking().first()
    }
    
    public func connect(username: String, password: String) -> Observable<Session> {
        let l = Login()
        l.username = username
        l.password = password
        return Observable.create {
            obs in
            let _ = self.login.login(l).subscribe {
                e in
                if let auth = e.element {
                    obs.onNext(Session(self.configuration, self.clientConfiguration, AuthenticationToken(auth.username, auth.accessToken)))
                } else {
                    obs.onCompleted()
                }
            }
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    public func blockingConnect(accessToken: String) throws -> Session? {
        return try self.connect(accessToken: accessToken).toBlocking().first()
    }
    
    public func connect(accessToken: String) -> Observable<Session> {
        return Observable.create {
            obs in
            obs.onNext(Session(self.configuration, self.clientConfiguration, AuthenticationToken(nil, accessToken)))
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    public func blockingResetPasswordByEmail(_ email: String) throws -> Reset? {
        return try resetPasswordByEmail(email).toBlocking().first()
    }
    
    public func resetPasswordByEmail(_ email: String) -> Observable<Reset> {
        let r = Reset()
        r.email = email
        return resetPassword(r)
    }
    
    public func blockingResetPassword(username: String) throws -> Reset? {
        return try resetPassword(username: username).toBlocking().first()
    }
    
    public func resetPassword(username: String) -> Observable<Reset> {
        let r = Reset()
        r.username = username
        return resetPassword(r)
    }
    
    private func resetPassword(_ resetIdentifier: Reset) -> Observable<Reset> {
        return reset.post(resetIdentifier)
    }
}
