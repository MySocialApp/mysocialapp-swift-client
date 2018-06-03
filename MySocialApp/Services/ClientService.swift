import Foundation

class ClientService {
    
    var session: Session
    
    lazy var account = RestAccount(self.session)
    lazy var commentable = RestCommentable(self.session)
    lazy var conversation = RestConversation(self.session)
    lazy var conversationMessage = RestConversationMessage(self.session)
    lazy var event = RestEvent(self.session)
    lazy var feed = RestFeed(self.session)
    lazy var friendRequest = RestFriendRequest(self.session)
    lazy var group = RestGroup(self.session)
    lazy var likeable = RestLikeable(self.session)
    lazy var login = RestLogin(self.session)
    lazy var notification = RestPreviewNotification(self.session)
    lazy var photo = RestPhoto(self.session)
    lazy var report = RestReport(self.session)
    lazy var reset = RestReset(self.session)
    lazy var search = RestSearch(self.session)
    lazy var status = RestStatus(self.session)
    lazy var textWallMessage = RestTextWallMessage(self.session)
    lazy var user = RestUser(self.session)

    init(_ session: Session) {
        self.session = session
    }
}
