import Foundation
import RxSwift

public class FluentUser {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }
    
    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }

    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<User>, offset: Int = 0) {
        guard offset < FluentUser.PAGE_SIZE else {
            self.stream(page+1, to, obs, offset: offset - FluentUser.PAGE_SIZE)
            return
        }
        let size = min(FluentUser.PAGE_SIZE,to - (page * FluentUser.PAGE_SIZE))
        if size > 0 {
            let _ = session.clientService.user.list(page, size: size).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < FluentUser.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to, obs)
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
    
    public func blockingStream(limit: Int = Int.max) throws -> [User] {
        return try self.list(page: 0, size: limit).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max) throws -> Observable<User> {
        return self.list(page: 0, size: limit)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [User] {
        return try self.list(page: page, size: size).toBlocking().toArray()
    }
    
    public func list(page: Int = 0, size: Int = 10) -> Observable<User> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > FluentUser.PAGE_SIZE {
                var offset = page*size
                let page = offset / FluentUser.PAGE_SIZE
                offset -= page * FluentUser.PAGE_SIZE
                self.stream(page, to, obs, offset: offset)
            } else {
                self.stream(page, to, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingGet(_ id: Int64) throws -> User? {
        return try self.get(id).toBlocking().first()
    }
    
    public func get(_ id: Int64) -> Observable<User> {
        return session.clientService.user.get(id)
    }

    public func blockingGetByExternalId(_ id: String) throws -> User? {
        return try getByExternalId(id).toBlocking().first()
    }
    
    public func getByExternalId(_ id: String) -> Observable<User> {
        return session.clientService.user.getByExternalId(id)
    }

    public func blockingSearch(_ search: Search, page: Int = 0, size: Int = 10) throws -> SearchResultValue<User>? {
        return try self.search(search, page: page, size: size).toBlocking().first()
    }
    
    public func search(_ search: Search, page: Int = 0, size: Int = 10) -> Observable<SearchResultValue<User>> {
        return Observable.create {
            obs in
            if size > 0 {
                let _ = self.session.clientService.search.get(page, size: size, params: search.toQueryParams()).subscribe {
                    e in
                    if let e = e.element?.resultsByType?.users {
                        obs.onNext(e)
                    } else if let e = e.error {
                        obs.onError(e)
                    } else {
                        let e = SearchResultValue<User>()
                        e.matchedCount = 0
                        obs.onNext(e)
                    }
                    obs.onCompleted()
                }
            } else {
                let e = SearchResultValue<User>()
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
            let _ = self.session.clientService.customField.list(for: User()).subscribe {
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
            private var mLocationMaximumDistance: Double? = nil
            private var mSortOrder: SortOrder? = nil
            private var mMatchAll: Bool? = nil
            private var mStartsWith: Bool? = true
            private var mEndsWith: Bool? = true

            public init() {}
            
            public func setFirstName(_ firstName: String) -> Builder {
                self.user.firstName = firstName
                return self
            }
            
            public func setLastName(_ lastName: String) -> Builder {
                self.user.lastName = lastName
                return self
            }
            
            public func setGender(_ gender: Gender) -> Builder {
                self.user.gender = gender
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
            
            public func setPresentation(_ presentation: String) -> Builder {
                self.user.presentation = presentation
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
                return Search(SearchQuery(user: user, q: nil, name: nil, content: nil, maximumDistanceInMeters: mLocationMaximumDistance, sortOrder: mSortOrder, startDate: nil, endDate: nil, dateField: nil, matchAll: mMatchAll, startsWith: mStartsWith, endsWith: mEndsWith))
            }
        }
        
        override func toQueryParams() -> [String: String] {
            var m = super.toQueryParams()
            m["type"] = "USER"
            return m
        }
    }
}
