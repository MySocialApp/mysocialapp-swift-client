import Foundation
import RxSwift

public class Event: BaseCustomField {
    private static let PAGE_SIZE = 10

    public var name: String?{
        get { return (super.getAttributeInstance("name") as! JSONableString?)?.string }
        set(name) { super.setStringAttribute(withName: "name", name) }
    }
    public var desc: String?{
        get { return (super.getAttributeInstance("description") as! JSONableString?)?.string }
        set(description) { super.setStringAttribute(withName: "description", description) }
    }
    public var startDate: Date?{
        get { return (super.getAttributeInstance("start_date") as! JSONableDate?)?.date }
        set(startDate) { super.setDateAttribute(withName: "start_date", startDate) }
    }
    public var endDate: Date?{
        get { return (super.getAttributeInstance("end_date") as! JSONableDate?)?.date }
        set(endDate) { super.setDateAttribute(withName: "end_date", endDate) }
    }
    public var location: Location?{
        get { return super.getAttributeInstance("location") as? Location }
        set(location) { super.setAttribute(withName: "location", location) }
    }
    public var staticMapsURL: String?{
        get { return (super.getAttributeInstance("static_maps_url") as! JSONableString?)?.string }
        set(staticMapsURL) { super.setStringAttribute(withName: "static_maps_url", staticMapsURL) }
    }
    public var maxSeats: Int64?{
        get { return (super.getAttributeInstance("max_seats") as! JSONableInt64?)?.int64 }
        set(maxSeats) { super.setInt64Attribute(withName: "max_seats", maxSeats) }
    }
    public var isCancelled: Bool?{
        get { return (super.getAttributeInstance("is_cancelled") as! JSONableBool?)?.bool }
        set(isCancelled) { super.setBoolAttribute(withName: "is_cancelled", isCancelled) }
    }
    public var freeSeats: Int?{
        get { return (super.getAttributeInstance("free_seats") as! JSONableInt?)?.int }
        set(freeSeats) { super.setIntAttribute(withName: "free_seats", freeSeats) }
    }
    public var eventMemberAccessControl: MemberAccessControl?{
        get { if let c = (super.getAttributeInstance("event_member_access_control") as! JSONableString?)?.string { return MemberAccessControl(rawValue: c) } else { return nil } }
        set(eventMemberAccessControl) { super.setStringAttribute(withName: "event_member_access_control", eventMemberAccessControl?.rawValue) }
    }
    public var members: [Member<EventStatus>]?{
        get { return (super.getAttributeInstance("members") as! JSONableArray<Member<EventStatus>>?)?.array }
        set(members) { super.setArrayAttribute(withName: "members", members) }
    }
    public var coverPhoto: Photo?{
        get { return super.getAttributeInstance("cover_photo") as? Photo }
        set(coverPhoto) { super.setAttribute(withName: "cover_photo", coverPhoto) }
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
    public var totalMembers: Int64?{
        get { return (super.getAttributeInstance("total_members") as! JSONableInt64?)?.int64 }
        set(totalMembers) { super.setInt64Attribute(withName: "total_members", totalMembers) }
    }
    internal var profileImage: UIImage? = nil
    internal var profileCoverImage: UIImage? = nil
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "name", "description", "static_maps_url", "event_member_access_control":
            return JSONableString().initAttributes
        case "max_seats", "total_members":
            return JSONableInt64().initAttributes
        case "distance_in_meters", "free_seats":
            return JSONableInt().initAttributes
        case "members":
            return JSONableArray<Member<EventStatus>>().initAttributes
        case "cover_photo", "profile_cover_photo":
            return Photo().initAttributes
        case "location":
            return Location().initAttributes
        case "is_member", "is_cancelled":
            return JSONableBool().initAttributes
        case "start_date", "end_date":
            return JSONableDate().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
        
    }

    public override func getBodyImageURL() -> String? {
        return staticMapsURL
    }
    
    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<Feed>) {
        if let session = self.session, to > 0 {
            let _ = session.clientService.feed.list(page, size: min(Event.PAGE_SIZE,to - (page * Event.PAGE_SIZE)), forEvent: self).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < Event.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to - Event.PAGE_SIZE, obs)
                    }
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
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    public func blockingSave() throws -> Event? {
        return try self.save().toBlocking().first()
    }
    
    public func save() -> Observable<Event> {
        if let s = session {
            if let _ = self.id {
                return s.clientService.event.update(self)
            } else {
                return s.clientService.event.post(self)
            }
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    public func blockingCancel() throws -> Event? {
        return try cancel().toBlocking().first()
    }
    
    public func cancel() -> Observable<Event> {
        if let s = session, let id = self.id {
            return s.clientService.event.cancel(id)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    public func blockingParticipate() throws -> User? {
        return try participate().toBlocking().first()
    }

    public func participate() -> Observable<User> {
        if let s = session {
            return s.clientService.user.join(event: self)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    public func blockingUnParticipate() throws -> Bool? {
        return try unParticipate().toBlocking().first()
    }

    public func unParticipate() -> Observable<Bool> {
        if let s = session {
            return s.clientService.user.unjoin(event: self)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    public class Builder {
        private var mName: String? = nil
        private var mDescription: String? = nil
        private var mStartDate: Date? = nil
        private var mEndDate: Date? = nil
        private var mLocation: Location? = nil
        private var mMaxSeats: Int64 = 10
        private var mMemberAccessControl = MemberAccessControl.Public
        private var mImage: UIImage? = nil
        private var mCoverImage: UIImage? = nil
        
        public init() {}
        
        public func setName(_ name: String) -> Builder {
            self.mName = name
            return self
        }
        
        public func setDescription(_ description: String) -> Builder {
            self.mDescription = description
            return self
        }
        
        public func setStartDate(_ date: Date) -> Builder {
            self.mStartDate = date
            return self
        }
        
        public func setEndDate(_ date: Date) -> Builder {
            self.mEndDate = date
            return self
        }
        
        public func setLocation(_ location: Location) -> Builder {
            self.mLocation = location
            return self
        }
        
        public func setMaxSeats(_ maxSeats: Int64) -> Builder {
            self.mMaxSeats = maxSeats
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
        
        public func build() throws -> Event {
            guard mName != nil && mName != "" else {
                let e = RestError()
                e.setStringAttribute(withName: "message", "Name cannot be null or empty")
                throw e
            }
        
            guard mDescription != nil && mDescription != "" else {
                let e = RestError()
                e.setStringAttribute(withName: "message", "Description cannot be null or empty")
                throw e
            }
        
            guard mStartDate != nil && mEndDate != nil else {
                let e = RestError()
                e.setStringAttribute(withName: "message", "Start date and end date cannot be null")
                throw e
            }
        
            guard Date().compare(mStartDate!) == ComparisonResult.orderedAscending else {
                let e = RestError()
                e.setStringAttribute(withName: "message", "Start date cannot be lower than now")
                throw e
            }
        
            guard mStartDate!.compare(mEndDate!) == ComparisonResult.orderedAscending else {
                let e = RestError()
                e.setStringAttribute(withName: "message", "Start date cannot be greater than end date")
                throw e
            }
        
            guard mLocation != nil else {
                let e = RestError()
                e.setStringAttribute(withName: "message", "Meeting location cannot be null or empty")
                throw e
            }
            
            let e = Event()
            e.name = mName
            e.desc = mDescription
            e.startDate = mStartDate
            e.endDate = mEndDate
            e.location = mLocation
            e.maxSeats = mMaxSeats
            e.eventMemberAccessControl = mMemberAccessControl
            e.profileImage = mImage
            e.profileCoverImage = mCoverImage
            return e
        }
    }
    
}
