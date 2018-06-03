import Foundation
import RxSwift

class FluentEvent {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    public init(_ session:  Session) {
        self.session = session
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
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func blockingGet(_ id: Int64) throws -> Event? {
        return try self.get(id).toBlocking().first()
    }
    
    func get(_ id: Int64) -> Observable<Event> {
        return session.clientService.event.get(id)
    }

    func blockingSearch(_ search: Search, page: Int = 0, size: Int = 10) throws -> SearchResultValue<Event>? {
        return try self.search(search, page: page, size: size).toBlocking().first()
    }
    
    func search(_ search: Search, page: Int = 0, size: Int = 10) -> Observable<SearchResultValue<Event>> {
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
                }
            } else {
                let e = SearchResultValue<Event>()
                e.matchedCount = 0
                obs.onNext(e)
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
        .subscribeOn(MainScheduler.instance)
    }
    
    class Search: ISearch {
    
    class Builder {
        private var user = User()
        private var mName: String? = nil
        private var mDescription: String? = nil
        private var mLocationMaximumDistance: Double? = nil
        private var mSortOrder: SortOrder? = nil
        private var mFromDate: Date? = nil
        private var mToDate: Date? = nil
        private var mDateField: DateField? = nil
    
        func setName(_ name: String) -> Builder {
            self.mName = name
            return self
        }
    
        func setDescription(_ description: String) -> Builder {
            self.mDescription = description
            return self
        }
    
        func setOwnerFirstName(_ firstName: String) -> Builder {
            self.user.firstName = firstName
            return self
        }
    
        func setOwnerLastName(_ lastName: String) -> Builder {
            self.user.lastName = lastName
            return self
        }
    
        func setLocation(_ location: Location) -> Builder {
            self.user.livingLocation = location
            return self
        }
    
        func setLocationMaximumDistanceInMeters(_ maximumDistance: Double) -> Builder {
            self.mLocationMaximumDistance = maximumDistance
            return self
        }
    
        func setLocationMaximumDistanceInKilometers(_ maximumDistance: Double) -> Builder {
            self.mLocationMaximumDistance = maximumDistance * 1000
            return self
        }
        
        func setOrder(_ sortOrder: SortOrder) -> Builder {
            self.mSortOrder = sortOrder
            return self
        }
        
        func setFromDate(_ fromDate: Date) -> Builder {
            self.mFromDate = fromDate
            return self
        }
        
        func setToDate(_ toDate: Date) -> Builder {
            self.mToDate = toDate
            return self
        }
        
        func setDateField(_ dateField: DateField) -> Builder {
            self.mDateField = dateField
            return self
        }

        func build() -> Search {
            return Search(SearchQuery(user: user, q: nil, name: mName, content: mDescription, maximumDistanceInMeters: mLocationMaximumDistance, sortOrder: mSortOrder, startDate: mFromDate, endDate: mToDate, dateField: mDateField?.rawValue))
        }
    }
        
        override func toQueryParams() -> [String: String] {
            var m = super.toQueryParams()
            m["type"] = "EVENT"
            return m
        }
        
        enum DateField: String {
            case startDate = "START_DATE"
            case endDate = "END_DATE"
        }
    }
}
