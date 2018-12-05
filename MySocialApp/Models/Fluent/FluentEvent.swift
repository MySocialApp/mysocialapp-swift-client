import Foundation
import RxSwift

public class FluentEvent {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }
    
    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }

    private func stream(_ page: Int, _ to: Int, with options: Options = Options(), _ obs: AnyObserver<Event>, offset: Int = 0) {
        guard offset < FluentEvent.PAGE_SIZE else {
            self.stream(page+1, to, obs, offset: offset - FluentEvent.PAGE_SIZE)
            return
        }
        let size = min(FluentEvent.PAGE_SIZE,to - (page * FluentEvent.PAGE_SIZE))
        if size > 0 {
            let _ = session.clientService.event.list(page, size: size, parameters: options.toQueryParams()).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < FluentEvent.PAGE_SIZE {
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
    
    private func getOptionsFromDate(_ date: Date?) -> Options {
        if let d = date {
            return Options.Builder().setFromDate(d).setDateField(.startDate).setSortField("start_date").build()
        } else {
            return Options()
        }
    }
    
    public func blockingStream(limit: Int = Int.max, from date: Date?) throws -> [Event] {
        return try self.blockingStream(limit:limit, with: getOptionsFromDate(date))
    }
    
    public func stream(limit: Int = Int.max, from date: Date?) -> Observable<Event> {
        return self.stream(limit: limit, with: getOptionsFromDate(date))
    }
    
    public func blockingList(page: Int = 0, size: Int = 10, from date: Date?) throws -> [Event] {
        return try self.list(page: page, size: size, with: getOptionsFromDate(date)).toBlocking().toArray()
    }
    
    public func list(page: Int = 0, size: Int = 10, from date: Date?) -> Observable<Event> {
        return self.list(page: page, size: size, with: getOptionsFromDate(date))
    }

    public func blockingStream(limit: Int = Int.max, with options: Options? = nil) throws -> [Event] {
        let options = options ?? Options()
        return try self.list(page: 0, size: limit, with: options).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max, with options: Options) -> Observable<Event> {
        return self.list(page: 0, size: limit, with: options)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10, with options: Options) throws -> [Event] {
        return try self.list(page: page, size: size, with: options).toBlocking().toArray()
    }
    
    public func list(page: Int = 0, size: Int = 10, with options: Options) -> Observable<Event> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > FluentEvent.PAGE_SIZE {
                var offset = page*size
                let page = offset / FluentEvent.PAGE_SIZE
                offset -= page * FluentEvent.PAGE_SIZE
                self.stream(page, to, with: options, obs, offset: offset)
            } else {
                self.stream(page, to, with: options, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingGet(_ id: Int64) throws -> Event? {
        return try self.get(id).toBlocking().first()
    }
    
    public func get(_ id: Int64) -> Observable<Event> {
        return session.clientService.event.get(id)
    }
    
    public func blockingCreate(_ event: Event) throws -> Event? {
        return try self.create(event).toBlocking().first()
    }
    
    public func create(_ event: Event) -> Observable<Event> {
        return Observable.create {
            obs in
            let _ = self.session.clientService.event.post(event).subscribe {
                e in
                if let e = e.element {
                    if let i = event.profileImage {
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
                    } else if let i = event.profileCoverImage {
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

    public func blockingSearch(_ search: Search, page: Int = 0, size: Int = 10) throws -> SearchResultValue<Event>? {
        return try self.search(search, page: page, size: size).toBlocking().first()
    }
    
    public func search(_ search: Search, page: Int = 0, size: Int = 10) -> Observable<SearchResultValue<Event>> {
        return Observable.create {
            obs in
            if size > 0 {
                let _ = self.session.clientService.search.get(page, size: size, params: search.toQueryParams()).subscribe {
                    e in
                    if let e = e.element?.resultsByType?.events {
                        obs.onNext(e)
                    } else if let e = e.error {
                        obs.onError(e)
                    } else {
                        let e = SearchResultValue<Event>()
                        e.matchedCount = 0
                        obs.onNext(e)
                    }
                    obs.onCompleted()
                }
            } else {
                let e = SearchResultValue<Event>()
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
            let _ = self.session.clientService.customField.list(for: Event()).subscribe {
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
            private var mFromDate: Date? = nil
            private var mToDate: Date? = nil
            private var mDateField: DateField? = nil
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
            
            public func setFromDate(_ fromDate: Date) -> Builder {
                self.mFromDate = fromDate
                return self
            }
            
            public func setToDate(_ toDate: Date) -> Builder {
                self.mToDate = toDate
                return self
            }
            
            public func setDateField(_ dateField: DateField) -> Builder {
                self.mDateField = dateField
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
                return Search(SearchQuery(user: user, q: nil, name: mName, content: mDescription, maximumDistanceInMeters: mLocationMaximumDistance, sortOrder: mSortOrder, startDate: mFromDate, endDate: mToDate, dateField: mDateField?.rawValue, matchAll: mMatchAll, startsWith: mStartsWith, endsWith: mEndsWith))
            }
        }
        
        override func toQueryParams() -> [String: String] {
            var m = super.toQueryParams()
            m["type"] = "EVENT"
            return m
        }
        
        public enum DateField: String {
            case startDate = "start_date"
            case endDate = "end_date"
        }
    }
    
    public class Options {
        var sortField: String? = nil
        var dateField: String? = nil
        var fromDate: Date? = nil
        var location: Location? = nil
        var limited: Bool? = nil
    
        public class Builder {
            private var mSortField: String? = "start_date"
            private var mDateField: DateField? = .startDate
            private var mFromDate: Date? = Date()
            private var mLocation: Location? = nil
            private var mLimited: Bool? = false
    
            public init() {}
            
            public func setSortField(_ name: String) -> Builder {
                self.mSortField = name
                return self
            }
    
            public func setDateField(_ dateField: DateField) -> Builder {
                self.mDateField = dateField
                return self
            }
    
            public func setFromDate(_ date: Date) -> Builder {
                self.mFromDate = date
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
                o.dateField = mDateField?.rawValue
                o.fromDate = mFromDate
                o.location = mLocation
                o.limited = mLimited
                return o
            }
    
            public enum DateField: String {
                case startDate = "start_date"
                case endDate = "end_date"
            }
        }
    
        func toQueryParams() -> [String:String] {
            var m: [String:String] = [:]
            if let f = sortField {
                m["sort_field"] = f
            }
            if let f = dateField {
                m["date_field"] = f
            }
            if let d = fromDate {
                m["from_date"] = DateUtils.toISO8601(d)
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
