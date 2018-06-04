import Foundation

public class AuthenticationToken {
    public var nickname: String?
    public var accessToken: String?
    
    internal init(_ nickname: String?, _ accessToken: String?) {
        self.nickname = nickname
        self.accessToken = accessToken
    }
}
