import Foundation
import RxSwift

public class User: BaseCustomField {
    private static let PAGE_SIZE = 10

    public var firstName: String?{
        get { return (super.getAttributeInstance("first_name") as! JSONableString?)?.string }
        set(firstName) { super.setStringAttribute(withName: "first_name", firstName) }
    }
    public var lastName: String?{
        get { return (super.getAttributeInstance("last_name") as! JSONableString?)?.string }
        set(lastName) { super.setStringAttribute(withName: "last_name", lastName) }
    }
    public var fullName: String?{
        get { return (super.getAttributeInstance("full_name") as! JSONableString?)?.string }
        set(fullName) { super.setStringAttribute(withName: "full_name", fullName) }
    }
    public var presentation: String?{
        get { return (super.getAttributeInstance("presentation") as! JSONableString?)?.string }
        set(presentation) { super.setStringAttribute(withName: "presentation", presentation) }
    }
    public var dateOfBirth: Date?{
        get { return (super.getAttributeInstance("date_of_birth") as! JSONableDate?)?.date }
        set(dateOfBirth) { super.setDateAttribute(withName: "date_of_birth", dateOfBirth) }
    }
    public var gender: Gender?{
        get { if let g = (super.getAttributeInstance("gender") as! JSONableString?)?.string { return Gender(rawValue: g) } else { return nil } }
        set(gender) { super.setStringAttribute(withName: "gender", gender?.rawValue) }
    }
    public var username: String?{
        get { return (super.getAttributeInstance("username") as! JSONableString?)?.string }
        set(username) { super.setStringAttribute(withName: "username", username) }
    }
    public var password: String?{
        get { return (super.getAttributeInstance("password") as! JSONableString?)?.string }
        set(password) { super.setStringAttribute(withName: "password", password) }
    }
    public var profilePhoto: Photo?{
        get { return super.getAttributeInstance("profile_photo") as? Photo }
        set(profilePhoto) { super.setAttribute(withName: "profile_photo", profilePhoto) }
    }
    public var profileCoverPhoto: Photo?{
        get { return super.getAttributeInstance("profile_cover_photo") as? Photo }
        set(profileCoverPhoto) { super.setAttribute(withName: "profile_cover_photo", profileCoverPhoto) }
    }
    public var email: String?{
        get { return (super.getAttributeInstance("email") as! JSONableString?)?.string }
        set(email) { super.setStringAttribute(withName: "email", email) }
    }
    public var currentStatus: Status?{
        get { return super.getAttributeInstance("current_status") as? Status }
        set(currentStatus) { super.setAttribute(withName: "current_status", currentStatus) }
    }
    public var commonFriends: [User]?{
        get { return (super.getAttributeInstance("common_friends") as! JSONableArray<User>?)?.array }
        set(commonFriends) { super.setArrayAttribute(withName: "common_friends", commonFriends) }
    }
    public var isFriend: Bool?{
        get { return (super.getAttributeInstance("is_friend") as! JSONableBool?)?.bool }
        set(isFriend) { super.setBoolAttribute(withName: "is_friend", isFriend) }
    }
    public var isRequestedAsFriend: Bool?{
        get { return (super.getAttributeInstance("is_requested_as_friend") as! JSONableBool?)?.bool }
        set(isRequestedAsFriend) { super.setBoolAttribute(withName: "is_requested_as_friend", isRequestedAsFriend) }
    }
    public var livingLocation: Location?{
        get { return super.getAttributeInstance("living_location") as? Location }
        set(livingLocation) { super.setAttribute(withName: "living_location", livingLocation) }
    }
    public var distance: Int?{
        get { return (super.getAttributeInstance("distance") as! JSONableInt?)?.int }
        set(distance) { super.setIntAttribute(withName: "distance", distance) }
    }
    public var flag: UserFlag?{
        get { return super.getAttributeInstance("flag") as? UserFlag }
        set(flag) { super.setAttribute(withName: "flag", flag) }
    }
    public var userStat: UserStat? {
        get { return super.getAttributeInstance("user_stat") as? UserStat }
        set(userStat) { super.setAttribute(withName: "user_stat", userStat) }
    }
    public var userSettings: UserSettings? {
        get { return super.getAttributeInstance("user_settings") as? UserSettings }
        set(userSettings) { super.setAttribute(withName: "user_settings", userSettings) }
    }
    public var spokenLanguage: InterfaceLanguage? {
        get { if let z = (super.getAttributeInstance("spoken_language") as! JSONableString?)?.string { return InterfaceLanguage(rawValue: z) } else { return nil } }
        set(spokenLanguage) { super.setStringAttribute(withName: "spoken_language", spokenLanguage?.rawValue) }
    }
    public var authorities: [String] {
        get { if let a = super.getAttributeInstance("authorities") as? JSONableArray<JSONableString> { return a.array.flatMap { $0.string } } else { return [] } }
    }
    public var externalId: String?{
        get { return (super.getAttributeInstance("external_id") as! JSONableString?)?.string }
        set(externalId) { super.setStringAttribute(withName: "external_id", externalId) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "first_name", "last_name", "full_name", "presentation", "gender", "username", "password", "email", "spoken_language", "external_id":
            return JSONableString().initAttributes
        case "date_of_birth":
            return JSONableDate().initAttributes
        case "profile_photo", "profile_cover_photo":
            return Photo().initAttributes
        case "current_status":
            return Status().initAttributes
        case "common_friends":
            return JSONableArray<User>().initAttributes
        case "is_friend", "is_requested_as_friend", "stat_status_active":
            return JSONableBool().initAttributes
        case "living_location":
            return Location().initAttributes
        case "distance":
            return JSONableInt().initAttributes
        case "flag":
            return UserFlag().initAttributes
        case "user_stat":
            return UserStat().initAttributes
        case "user_settings":
            return UserSettings().initAttributes
        case "authorities":
            return JSONableArray<JSONableString>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public override func getBodyImageURL() -> String? {
        return self.displayedPhoto?.getBodyImageURL()
    }
    
    public func blockingSave() throws -> User? {
        return try self.save().toBlocking().first()
    }
    
    public func save() -> Observable<User> {
        if let s = self.session {
            return s.clientService.account.update(self)
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
    
    public func blockingChangeProfilePhoto(_ image: UIImage) throws -> Photo? {
        return try self.changeProfilePhoto(image).toBlocking().first()
    }
    
    public func changeProfilePhoto(_ image: UIImage) -> Observable<Photo> {
        return Observable.create {
            obs in
            if let s = self.session {
                s.clientService.photo.postPhoto(image, forModel: self) {
                    e in
                    if let e = e {
                        obs.onNext(e)
                    } else {
                        let e = MySocialAppException()
                        e.setStringAttribute(withName: "message", "An error occured while uploading profile photo")
                        obs.onError(e)
                    }
                }
            } else {
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingChangeProfileCoverPhoto(_ image: UIImage) throws -> Photo? {
        return try self.changeProfileCoverPhoto(image).toBlocking().first()
    }

    public func changeProfileCoverPhoto(_ image: UIImage) -> Observable<Photo> {
        return Observable.create {
            obs in
            if let s = self.session {
                s.clientService.photo.postPhoto(image, forModel: self, forCover: true) {
                    e in
                    if let e = e {
                        obs.onNext(e)
                    } else {
                        let e = MySocialAppException()
                        e.setStringAttribute(withName: "message", "An error occured while uploading profile cover photo")
                        obs.onError(e)
                    }
                }
            } else {
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }

    public func blockingRequestAsFriend() throws -> User? {
        return try requestAsFriend().toBlocking().first()
    }
    
    public func requestAsFriend() -> Observable<User> {
        if let s = self.session {
            return s.clientService.user.requestAsFriend(self)
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
    
    public func blockingCancelFriendRequest() throws -> Bool? {
        return try cancelFriendRequest().toBlocking().first()
    }
    
    public func cancelFriendRequest() -> Observable<Bool> {
        if let s = self.session {
            return s.clientService.user.cancelRequestAsFriend(self)
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
    
    public func blockingAcceptFriendRequest() throws -> User? {
        return try acceptFriendRequest().toBlocking().first()
    }
    
    public func acceptFriendRequest() -> Observable<User> {
        if let s = self.session {
            return s.clientService.user.acceptAsFriend(self)
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
    
    public func blockingRefuseFriendRequest() throws -> Bool? {
        return try refuseFriendRequest().toBlocking().first()
    }
    
    public func refuseFriendRequest() -> Observable<Bool> {
        if let s = self.session {
            return s.clientService.user.refuseAsFriend(self)
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
    
    private func streamFriends(_ page: Int, _ to: Int, _ obs: AnyObserver<User>, offset: Int = 0) {
        guard offset < User.PAGE_SIZE else {
            self.streamFriends(page+1, to, obs, offset: offset - User.PAGE_SIZE)
            return
        }
        let size = min(User.PAGE_SIZE,to - (page * User.PAGE_SIZE))
        if size > 0, let session = self.session {
            let _ = session.clientService.user.list(page, size: size, friendsWith: self).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < User.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.streamFriends(page + 1, to, obs)
                    }
                } else if let error = e.error {
                    obs.onError(error)
                    obs.onCompleted()
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }
    
    public func blockingListFriends() throws -> [User]? {
        return try listFriends().toBlocking().toArray()
    }
    
    public func listFriends() -> Observable<User> {
        return Observable.create {
            obs in
            self.streamFriends(0, Int.max, obs)
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    private func streamFeed(_ page: Int, _ to: Int, _ obs: AnyObserver<Feed>, offset: Int = 0) {
        guard offset < User.PAGE_SIZE else {
            self.streamFeed(page+1, to, obs, offset: offset - User.PAGE_SIZE)
            return
        }
        let size = min(User.PAGE_SIZE,to - (page * User.PAGE_SIZE))
        if size > 0, let session = self.session {
            let _ = session.clientService.feed.list(page, size: size, forUser: self).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < User.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.streamFeed(page + 1, to, obs)
                    }
                } else if let error = e.error {
                    obs.onError(error)
                    obs.onCompleted()
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }
    
    public func blockingStreamNewsFeed(limit: Int = Int.max) throws -> [Feed]? {
        return try streamNewsFeed(limit: limit).toBlocking().toArray()
    }
    
    public func streamNewsFeed(limit: Int = Int.max) -> Observable<Feed> {
        return listNewsFeed(page: 0, size: limit)
    }
    
    public func blockingListNewsFeed(page: Int = 0, size: Int = 10) throws -> [Feed] {
        return try listNewsFeed(page: page, size: size).toBlocking().toArray()
    }
    
    public func listNewsFeed(page: Int = 0, size: Int = 10) -> Observable<Feed> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > User.PAGE_SIZE {
                var offset = page*size
                let page = offset / User.PAGE_SIZE
                offset -= page * User.PAGE_SIZE
                self.streamFeed(page, to, obs, offset: offset)
            } else {
                self.streamFeed(page, to, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingSendPrivateMessage(_ conversationMessagePost: ConversationMessagePost) throws -> ConversationMessage? {
        return try sendPrivateMessage(conversationMessagePost).toBlocking().first()
    }
    
    public func sendPrivateMessage(_ conversationMessagePost: ConversationMessagePost) -> Observable<ConversationMessage> {
        if let s = session {
            return Observable.create {
                obs in
                let conversation = Conversation()
                conversation.members = [self]
                let _ = s.clientService.conversation.post(conversation).subscribe {
                    e in
                    if let e = e.element {
                        let _ = e.sendMessage(conversationMessagePost).subscribe {
                            e in
                            if let e = e.element {
                                obs.onNext(e)
                            } else if let e = e.error {
                                obs.onError(e)
                            }
                            obs.onCompleted()
                        }
                    }
                }
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                obs.onCompleted()
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
    
    private func streamGroup(_ page: Int, _ to: Int, _ obs: AnyObserver<Group>, offset: Int = 0) {
        guard offset < User.PAGE_SIZE else {
            self.streamGroup(page+1, to, obs, offset: offset - User.PAGE_SIZE)
            return
        }
        let size = min(User.PAGE_SIZE,to - (page * User.PAGE_SIZE))
        if size > 0, let session = self.session {
            let _ = session.clientService.group.list(forUser: self, page: page, size: size).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < User.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.streamGroup(page + 1, to, obs)
                    }
                } else if let error = e.error {
                    obs.onError(error)
                    obs.onCompleted()
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }

    public func blockingStreamGroup(limit: Int = Int.max) throws -> [Group] {
        return try streamGroup(limit: limit).toBlocking().toArray()
    }
    
    public func streamGroup(limit: Int = Int.max) -> Observable<Group> {
        return listGroup(page: 0, size: limit)
    }
    
    public func blockingListGroup(page: Int = 0, size: Int = 10) throws -> [Group] {
        return try listGroup(page: page, size: size).toBlocking().toArray()
    }
    
    public func listGroup(page: Int = 0, size: Int = 10) -> Observable<Group> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > User.PAGE_SIZE {
                var offset = page*size
                let page = offset / User.PAGE_SIZE
                offset -= page * User.PAGE_SIZE
                self.streamGroup(page, to, obs, offset: offset)
            } else {
                self.streamGroup(page, to, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    private func streamEvent(_ page: Int, _ to: Int, _ obs: AnyObserver<Event>, offset: Int = 0) {
        guard offset < User.PAGE_SIZE else {
            self.streamEvent(page+1, to, obs, offset: offset - User.PAGE_SIZE)
            return
        }
        let size = min(User.PAGE_SIZE,to - (page * User.PAGE_SIZE))
        if size > 0, let session = self.session, let id = self.id {
            let _ = session.clientService.event.list(forMember: id, page: page, size: size).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < User.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.streamEvent(page + 1, to, obs)
                    }
                } else if let error = e.error {
                    obs.onError(error)
                    obs.onCompleted()
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }

    public func blockingStreamEvent(limit: Int = Int.max) throws -> [Event] {
        return try streamEvent(limit: limit).toBlocking().toArray()
    }
    
    public func streamEvent(limit: Int = Int.max) -> Observable<Event> {
        return listEvent(page: 0, size: limit)
    }
    
    public func blockingListEvent(page: Int = 0, size: Int = 10) throws -> [Event] {
        return try listEvent(page: page, size: size).toBlocking().toArray()
    }
    
    public func listEvent(page: Int = 0, size: Int = 10) -> Observable<Event> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > User.PAGE_SIZE {
                var offset = page*size
                let page = offset / User.PAGE_SIZE
                offset -= page * User.PAGE_SIZE
                self.streamEvent(page, to, obs, offset: offset)
            } else {
                self.streamEvent(page, to, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
}
