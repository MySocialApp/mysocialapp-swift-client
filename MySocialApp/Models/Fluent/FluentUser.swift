import Foundation
import RxSwift

public class FluentUser {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }
    
    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<User>) {
        if to > 0 {
            let _ = session.clientService.user.list(page, size: min(FluentUser.PAGE_SIZE,to - (page * FluentUser.PAGE_SIZE))).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < FluentUser.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to - FluentUser.PAGE_SIZE, obs)
                    }
                } else if let e = e.error {
                    obs.onError(e)
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
            self.stream(page, size, obs)
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
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
                }
            } else {
                let e = SearchResultValue<User>()
                e.matchedCount = 0
                obs.onNext(e)
            }
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    public class Search: ISearch {
        
        public class Builder {
            private var user = User()
            private var mLocationMaximumDistance: Double? = nil
            private var mSortOrder: SortOrder? = nil
            
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
            
            public func build() -> Search {
                return Search(SearchQuery(user: user, q: nil, name: nil, content: nil, maximumDistanceInMeters: mLocationMaximumDistance, sortOrder: mSortOrder, startDate: nil, endDate: nil, dateField: nil))
            }
        }
        
        override func toQueryParams() -> [String: String] {
            var m = super.toQueryParams()
            m["type"] = "USER"
            return m
        }
    }
}
