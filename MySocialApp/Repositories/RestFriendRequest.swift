import Foundation
import RxSwift

class RestFriendRequest: RestBase<FriendRequest, FriendRequest> {
    
    func list() -> Observable<FriendRequest> {
        return super.get("/friend/request")
    }
}
