import Foundation
import RxSwift

public class Group: BaseCustomField {
    private static let PAGE_SIZE = 10

    public var name: String?{
        get { return (super.getAttributeInstance("name") as! JSONableString?)?.string }
        set(name) { super.setStringAttribute(withName: "name", name) }
    }
    public var desc: String?{
        get { return (super.getAttributeInstance("description") as! JSONableString?)?.string }
        set(description) { super.setStringAttribute(withName: "description", description) }
    }
    public var location: Location?{
        get { return super.getAttributeInstance("location") as? Location }
        set(location) { super.setAttribute(withName: "location", location) }
    }
    public var isApprovable: Bool?{
        get { return (super.getAttributeInstance("is_approvable") as! JSONableBool?)?.bool }
        set(isCancelled) { super.setBoolAttribute(withName: "is_approvable", isCancelled) }
    }
    public var groupMemberAccessControl: MemberAccessControl?{
        get { if let c = (super.getAttributeInstance("group_member_access_control") as! JSONableString?)?.string { return MemberAccessControl(rawValue: c) } else { return nil } }
        set(groupMemberAccessControl) { super.setStringAttribute(withName: "group_member_access_control", groupMemberAccessControl?.rawValue) }
    }
    public var members: [Member<GroupStatus>]?{
        get { return (super.getAttributeInstance("members") as! JSONableArray<Member<GroupStatus>>?)?.array }
        set(members) { super.setArrayAttribute(withName: "members", members) }
    }
    public var memberCount: Int {
        get { if let t = totalMembers { return t } else if let m = members { return m.filter { $0.status == GroupStatus.Member }.count } else { return 0 } }
    }
    public var totalMembers: Int? {
        get { return (super.getAttributeInstance("total_members") as! JSONableInt?)?.int }
        set(totalMembers) { super.setIntAttribute(withName: "total_members", totalMembers) }
    }
    public var profilePhoto: Photo?{
        get { return super.getAttributeInstance("profile_photo") as? Photo }
        set(profilePhoto) { super.setAttribute(withName: "profile_photo", profilePhoto) }
    }
    public var profileCoverPhoto: Photo?{
        get { return super.getAttributeInstance("profile_cover_photo") as? Photo }
        set(profileCoverPhoto) { super.setAttribute(withName: "profile_cover_photo", profileCoverPhoto) }
    }
    public var isMember: Bool?{
        get { return (super.getAttributeInstance("is_member") as! JSONableBool?)?.bool }
        set(isMember) { super.setBoolAttribute(withName: "is_member", isMember) }
    }
    public var distanceInMeters: Int?{
        get { return (super.getAttributeInstance("distance_in_meters") as! JSONableInt?)?.int }
        set(distanceInMeters) { super.setIntAttribute(withName: "distance_in_meters", distanceInMeters) }
    }
    internal var profileImage: UIImage? = nil
    internal var profileCoverImage: UIImage? = nil

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "name", "description", "group_member_access_control":
            return JSONableString().initAttributes
        case "distance_in_meters", "total_members":
            return JSONableInt().initAttributes
        case "members":
            return JSONableArray<Member<GroupStatus>>().initAttributes
        case "profile_photo", "profile_cover_photo":
            return Photo().initAttributes
        case "location":
            return Location().initAttributes
        case "is_member", "is_approvable":
            return JSONableBool().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
        
    }
    
    public override func getDisplayedName() -> String? {
        return name
    }
    
    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<Feed>) {
        if let session = self.session, to > 0 {
            let _ = session.clientService.feed.list(page, size: min(Group.PAGE_SIZE,to - (page * Group.PAGE_SIZE)), forGroup: self).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < Group.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to - Group.PAGE_SIZE, obs)
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
    
    public func blockingStreamNewsFeed(limit: Int = Int.max) throws -> [Feed] {
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
            self.stream(page, size, obs)
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingSave() throws -> Group? {
        return try self.save().toBlocking().first()
    }
    
    public func save() -> Observable<Group> {
        if let s = session {
            if let _ = self.id {
                return s.clientService.group.update(self)
            } else {
                return s.clientService.group.post(self)
            }
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
    
    public func getMembers() -> Observable<Member<GroupStatus>> {
        return Observable.create {
            obs in
            if let s = self.session, let id = self.id {
                let _ = s.clientService.group.get(id, limited: false).subscribe {
                    e in
                    if let e = e.element {
                        e.members?.forEach { obs.onNext($0) }
                    } else if let error = e.error {
                        obs.onError(error)
                    }
                    obs.onCompleted()
                }
            } else {
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingGetMembers() throws -> [Member<GroupStatus>] {
        return try getMembers().toBlocking().toArray()
    }

    public func blockingJoin() throws -> User? {
        return try join().toBlocking().first()
    }
    
    public func join() -> Observable<User> {
        if let s = session {
            return s.clientService.user.join(group: self)
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
    
    public func blockingUnJoin() throws -> Bool? {
        return try unJoin().toBlocking().first()
    }
    
    public func unJoin() -> Observable<Bool> {
        if let s = session {
            return s.clientService.user.unjoin(group: self)
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
    
    public class Builder {
        private var mName: String? = nil
        private var mDescription: String? = nil
        private var mLocation: Location? = nil
        private var mMemberAccessControl = MemberAccessControl.Public
        private var mImage: UIImage? = nil
        private var mCoverImage: UIImage? = nil
        private var mCustomFields: [CustomField]? = nil

        public init() {}
        
        public func setName(_ name: String) -> Builder {
            self.mName = name
            return self
        }
        
        public func setDescription(_ description: String) -> Builder {
            self.mDescription = description
            return self
        }
        
        public func setLocation(_ location: Location) -> Builder {
            self.mLocation = location
            return self
        }
        
        public func setMemberAccessControl(_ memberAccessControl: MemberAccessControl) -> Builder {
            self.mMemberAccessControl = memberAccessControl
            return self
        }
        
        public func setImage(_ image: UIImage) -> Builder {
            self.mImage = image
            return self
        }
        
        public func setCoverImage(_ image: UIImage) -> Builder {
            self.mCoverImage = image
            return self
        }
        
        public func setCustomFields(_ customFields: [CustomField]) -> Builder {
            self.mCustomFields = customFields
            return self
        }

        public func build() throws -> Group {
            guard mName != nil && mName != "" else {
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "Name cannot be null or empty")
                throw e
            }
            
            guard mDescription != nil && mDescription != "" else {
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "Description cannot be null or empty")
                throw e
            }
            
            guard mLocation != nil else {
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "Meeting location cannot be null or empty")
                throw e
            }
            
            let g = Group()
            g.name = mName
            g.desc = mDescription
            g.location = mLocation
            g.groupMemberAccessControl = mMemberAccessControl
            g.profileImage = mImage
            g.profileCoverImage = mCoverImage
            if let cf = mCustomFields {
                g.setCustomFields(cf)
            }
            return g
        }
    }
}

