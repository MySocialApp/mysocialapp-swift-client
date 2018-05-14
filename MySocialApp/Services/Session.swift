import Foundation

internal class Session {
    internal var configuration: Configuration
    internal var clientConfiguration: ClientConfiguration
    internal var authenticationToken: AuthenticationToken
    internal lazy var clientService: ClientService = ClientService(self)
    
    init(_ configuration: Configuration, _ clientConfiguration: ClientConfiguration, _ authenticationToken: AuthenticationToken) {
        self.configuration = configuration
        self.clientConfiguration = clientConfiguration
        self.authenticationToken = authenticationToken
    }
}
