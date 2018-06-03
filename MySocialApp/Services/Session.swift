import Foundation
import RxSwift

internal class Session {
    internal var configuration: Configuration
    internal var clientConfiguration: ClientConfiguration
    internal var authenticationToken: AuthenticationToken
    internal lazy var clientService: ClientService = ClientService(self)
    
    public lazy var account = FluentAccount(self)
    public lazy var newsFeed = FluentFeed(self)
    public lazy var user = FluentUser(self)
    public lazy var friend = FluentFriend(self)
    public lazy var notification = FluentNotification(self)
    public lazy var conversation = FluentConversation(self)
    public lazy var group = FluentGroup(self)
    public lazy var event = FluentEvent(self)
    
    init(_ configuration: Configuration, _ clientConfiguration: ClientConfiguration, _ authenticationToken: AuthenticationToken) {
        self.configuration = configuration
        self.clientConfiguration = clientConfiguration
        self.authenticationToken = authenticationToken
    }
    
    func disconnect() -> Observable<Void> {
        return clientService.login.logout()
    }
}
