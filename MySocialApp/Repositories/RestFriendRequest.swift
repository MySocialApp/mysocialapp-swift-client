import Foundation
import RxSwift

class RestFriendRequest: RestBase<FriendRequests, FriendRequests> {
    
    func list() -> Observable<FriendRequests> {
        return super.get("/friend/request")
    }
}
