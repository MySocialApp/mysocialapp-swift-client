import Foundation

internal class Session {
    internal var configuration: Configuration
    internal var clientConfiguration: ClientConfiguration
    internal var authenticationToken: AuthenticationToken
    internal lazy var clientService: ClientService = ClientService(self)
    
    public lazy var account: FluentAccount = FluentAccount(self)
    public lazy var newsFeed: FluentFeed = FluentFeed(self)
    
    init(_ configuration: Configuration, _ clientConfiguration: ClientConfiguration, _ authenticationToken: AuthenticationToken) {
        self.configuration = configuration
        self.clientConfiguration = clientConfiguration
        self.authenticationToken = authenticationToken
    }
}
