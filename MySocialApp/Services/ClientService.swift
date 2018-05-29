import Foundation

class ClientService {
    
    var session: Session
    
    lazy var reset = RestReset(self.session)
    lazy var account = RestAccount(self.session)
    lazy var login = RestLogin(self.session)
    lazy var conversation = RestConversation(self.session)
    lazy var feed = RestFeed(self.session)
    lazy var commentable = RestCommentable(self.session)
    lazy var likeable = RestLikeable(self.session)
    lazy var photo = RestPhoto(self.session)
    lazy var status = RestStatus(self.session)
    lazy var user = RestUser(self.session)
    lazy var friendRequest = RestFriendRequest(self.session)
    lazy var textWallMessage = RestTextWallMessage(self.session)

    init(_ session: Session) {
        self.session = session
    }
}
