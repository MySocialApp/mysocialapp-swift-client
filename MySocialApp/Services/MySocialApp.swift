import Foundation
import RxBlocking

class MySocialApp {
    
    private var configuration: Configuration
    private var clientConfiguration: ClientConfiguration
    private lazy var login = RestLogin(nil)
    private lazy var account = RestAccount(nil)
    
    internal init(_ builder: Builder) {
        self.configuration = Configuration(appId: builder.mAppId)
        self.clientConfiguration = builder.mClientConfiguration
    }
    
    class Builder {
        internal var mAppId: String = ""
        internal var mClientConfiguration: ClientConfiguration = ClientConfiguration()
        
        func setAppId(_ appId: String) -> Builder {
            self.mAppId = appId
            return self
        }
        
        func setClientConfiguration(_ clientConfiguration: ClientConfiguration) -> Builder {
            self.mClientConfiguration = clientConfiguration
            return self
        }
        
        func build() -> MySocialApp {
            return MySocialApp(self)
        }
    }

    func createAccount(username: String, email: String, password: String, firstName: String? = nil) throws -> Session? {
        let user = User()
        user.username = username
        if let n = firstName {
            user.firstName = n
        } else {
            user.firstName = username
        }
        user.email = email
        user.password = password
        
        if let _ = try account.create(user).toBlocking().first() {
            return try self.connect(username: username, password: password)
        }
        return nil
    }
    
    func connectByEmail(email: String, password: String) throws -> Session? {
        return try self.connect(username: email, password: password)
    }
    
    func connect(username: String, password: String) throws -> Session? {
        let l = Login()
        l.username = username
        l.password = password
        
        if let auth = try login.login(l).toBlocking().first() {
            return Session(configuration, clientConfiguration, AuthenticationToken(auth.username, auth.accessToken))
        }
        return nil
    }
}
