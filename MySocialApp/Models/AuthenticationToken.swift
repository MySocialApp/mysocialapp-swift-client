import Foundation

class AuthenticationToken {
    var nickname: String?
    var accessToken: String?
    
    internal init(_ nickname: String?, _ accessToken: String?) {
        self.nickname = nickname
        self.accessToken = accessToken
    }
}
