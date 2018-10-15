import Foundation

internal struct Configuration {
    internal let appId: String
    internal let apiEndpointURL: String?
    
    internal var completeAPIEndpointURL: String {
        get {
            if let url = apiEndpointURL {
                return "\(url)/api/v1"
            } else {
                return "https://\(appId)-api.mysocialapp.io/api/v1"
            }
        }
    }
}
