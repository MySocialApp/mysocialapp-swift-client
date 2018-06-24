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

    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<Event>) {
        if to > 0 {
            let _ = session.clientService.event.list(page, size: min(FluentEvent.PAGE_SIZE,to - (page * FluentEvent.PAGE_SIZE))).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < FluentEvent.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to - FluentEvent.PAGE_SIZE, obs)
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
    
    public func blockingStream(limit: Int = Int.max) throws -> [Event] {
        return try self.list(page: 0, size: limit).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max) throws -> Observable<Event> {
        return self.list(page: 0, size: limit)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [Event] {
        return try self.list(page: page, size: size).toBlocking().toArray()
    }
    
    public func list(page: Int = 0, size: Int = 10) -> Observable<Event> {
        return Observable.create {
            obs in
            self.stream(page, size, obs)
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
                } else if let e = e.error {
                    obs.onError(e)
                }
                obs.onCompleted()
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
            case startDate = "START_DATE"
            case endDate = "END_DATE"
        }
    }
}
