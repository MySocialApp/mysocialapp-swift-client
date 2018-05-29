import Foundation
import RxSwift

class FluentFriend {
    
    var session: Session
    
    public init(_ session:  Session) {
        self.session = session
    }

    public func listFriendRequests() -> Observable<FriendRequest> {
        return self.session.clientService.friendRequest.list()
    }
}
