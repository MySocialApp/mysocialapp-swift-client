import Foundation
import RxSwift

public class FluentGroup {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }
    
    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }

    private func stream(_ page: Int, _ to: Int, with options: Options = Options(), _ obs: AnyObserver<Group>, offset: Int = 0) {
        guard offset < FluentGroup.PAGE_SIZE else {
            self.stream(page+1, to, obs, offset: offset - FluentGroup.PAGE_SIZE)
            return
        }
        let size = min(FluentGroup.PAGE_SIZE,to - (page * FluentGroup.PAGE_SIZE))
        if size > 0 {
            let _ = session.clientService.group.list(page, size: size, parameters: options.toQueryParams()).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < FluentGroup.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to, with: options, obs)
                    }
                } else if let e = e.error {
                    obs.onError(e)
                    obs.onCompleted()
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }
    
    public func blockingStream(limit: Int = Int.max, with options: Options? = nil) throws -> [Group] {
        let options = options ?? Options()
        return try self.list(page: 0, size: limit, with: options).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max, with options: Options) throws -> Observable<Group> {
        return self.list(page: 0, size: limit, with: options)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10, with options: Options) throws -> [Group] {
        return try self.list(page: page, size: size, with: options).toBlocking().toArray()
    }
    
    public func list(page: Int = 0, size: Int = 10, with options: Options) -> Observable<Group> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > FluentGroup.PAGE_SIZE {
                var offset = page*size
                let page = offset / FluentGroup.PAGE_SIZE
                offset -= page * FluentGroup.PAGE_SIZE
                self.stream(page, to, with: options, obs, offset: offset)
            } else {
                self.stream(page, to, with: options, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingGet(_ id: Int64) throws -> Group? {
        return try self.get(id).toBlocking().first()
    }
    
    public func get(_ id: Int64) -> Observable<Group> {
        return session.clientService.group.get(id)
    }
    
    public func blockingCreate(_ group: Group) throws -> Group? {
        return try self.create(group).toBlocking().first()
    }
    
    public func create(_ group: Group) -> Observable<Group> {
        return Observable.create {
            obs in
            let _ = self.session.clientService.group.post(group).subscribe {
                e in
                if let e = e.element {
                    if let i = group.profileImage {
                        self.session.clientService.photo.postPhoto(i, forModel: e, forCover: false) {
                            photo in
                            if let _ = photo {
                                e.profileImage = nil
                                if let i = e.profileCoverImage {
                                    self.session.clientService.photo.postPhoto(i, forModel: e, forCover: false) {
                                        photo in
                                        if let _ = photo {
                                            e.profileCoverImage = nil
                                            obs.onNext(e)
                                        }
                                        obs.onCompleted()
                                    }
                                } else {
                                    obs.onNext(e)
                                    obs.onCompleted()
                                }
                            } else {
                                obs.onCompleted()
                            }
                        }
                    } else if let i = group.profileCoverImage {
                        self.session.clientService.photo.postPhoto(i, forModel: e, forCover: false) {
                            photo in
                            if let _ = photo {
                                e.profileCoverImage = nil
                                obs.onNext(e)
                            }
                            obs.onCompleted()
                        }
                    } else {
                        obs.onNext(e)
                        obs.onCompleted()
                    }
                } else {
                    if let e = e.error {
                        obs.onError(e)
                    }
                    obs.onCompleted()
                }
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }

    public func blockingSearch(_ search: Search, page: Int = 0, size: Int = 10) throws -> SearchResultValue<Group>? {
        return try self.search(search, page: page, size: size).toBlocking().first()
    }
    
    public func search(_ search: Search, page: Int = 0, size: Int = 10) -> Observable<SearchResultValue<Group>> {
        return Observable.create {
            obs in
            if size > 0 {
                let _ = self.session.clientService.search.get(page, size: size, params: search.toQueryParams()).subscribe {
                    e in
                    if let e = e.element?.resultsByType?.groups {
                        obs.onNext(e)
                    } else if let e = e.error {
                        obs.onError(e)
                    } else {
                        let e = SearchResultValue<Group>()
                        e.matchedCount = 0
                        obs.onNext(e)
                    }
                    obs.onCompleted()
                }
            } else {
                let e = SearchResultValue<Group>()
                e.matchedCount = 0
                obs.onNext(e)
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingGetAvailableCustomFields() throws -> [CustomField] {
        return try getAvailableCustomFields().toBlocking().toArray()
    }
    
    public func getAvailableCustomFields() -> Observable<CustomField> {
        return Observable.create {
            obs in
            let _ = self.session.clientService.customField.list(for: Group()).subscribe {
                e in
                if let e = e.element?.array {
                    e.forEach { obs.onNext($0) }
                } else if let error = e.error {
                    obs.onError(error)
                }
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }

    public class Search: ISearch {
        
        public class Builder {
            private var user = User()
            private var mName: String? = nil
            private var mDescription: String? = nil
            private var mLocationMaximumDistance: Double? = nil
            private var mSortOrder: SortOrder? = nil
            private var mMatchAll: Bool? = nil
            private var mStartsWith: Bool? = true
            private var mEndsWith: Bool? = true

            public init() {}
            
            public func setName(_ name: String) -> Builder {
                self.mName = name
                return self
            }
            
            public func setDescription(_ description: String) -> Builder {
                self.mDescription = description
                return self
            }
            
            public func setOwnerFirstName(_ firstName: String) -> Builder {
                self.user.firstName = firstName
                return self
            }
            
            public func setOwnerLastName(_ lastName: String) -> Builder {
                self.user.lastName = lastName
                return self
            }
            
            public func setLocation(_ location: Location) -> Builder {
                self.user.livingLocation = location
                return self
            }
            
            public func setLocationMaximumDistanceInMeters(_ maximumDistance: Double) -> Builder {
                self.mLocationMaximumDistance = maximumDistance
                return self
            }
            
            public func setLocationMaximumDistanceInKilometers(_ maximumDistance: Double) -> Builder {
                self.mLocationMaximumDistance = maximumDistance * 1000
                return self
            }
            
            public func setOrder(_ sortOrder: SortOrder) -> Builder {
                self.mSortOrder = sortOrder
                return self
            }
            
            public func mustMatchAll(_ matchAll: Bool) -> Builder {
                self.mMatchAll = matchAll
                return self
            }
            
            public func mustStartWith(_ startsWith: Bool) -> Builder {
                self.mStartsWith = startsWith
                return self
            }
            
            public func mustEndWith(_ endsWith: Bool) -> Builder {
                self.mEndsWith = endsWith
                return self
            }

            public func build() -> Search {
                return Search(SearchQuery(user: user, q: nil, name: mName, content: mDescription, maximumDistanceInMeters: mLocationMaximumDistance, sortOrder: mSortOrder, startDate: nil, endDate: nil, dateField: nil, matchAll: mMatchAll, startsWith: mStartsWith, endsWith: mEndsWith))
            }
        }
        
        override func toQueryParams() -> [String: String] {
            var m = super.toQueryParams()
            m["type"] = "GROUP"
            return m
        }
    }
    
    public class Options {
        var sortField: String? = nil
        var location: Location? = nil
        var limited: Bool? = nil
        
        public class Builder {
            private var mSortField: String? = nil
            private var mLocation: Location? = nil
            private var mLimited: Bool? = false
            
            public init() {}
            
            public func setSortField(_ name: String) -> Builder {
                self.mSortField = name
                return self
            }
            
            public func setLocation(_ location: Location) -> Builder {
                self.mLocation = location
                return self
            }
            
            public func setLimited(_ limited: Bool) -> Builder {
                self.mLimited = limited
                return self
            }
            
            public func build() -> Options {
                let o = Options()
                o.sortField = mSortField
                o.location = mLocation
                o.limited = mLimited
                return o
            }
        }
        
        func toQueryParams() -> [String:String] {
            var m: [String:String] = [:]
            if let f = sortField {
                m["sort_field"] = f
            }
            if let lat = location?.latitude, let lon = location?.longitude {
                m["latitude"] = "\(lat)"
                m["longitude"] = "\(lon)"
            }
            if let l = limited {
                m["limited"] = "\(l)"
            }
            return m
        }
    }
}
