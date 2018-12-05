import Foundation
import RxSwift

public class FluentFeed {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }
    
    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }

    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<Feed>, offset: Int = 0) {
        guard offset < FluentFeed.PAGE_SIZE else {
            self.stream(page+1, to, obs, offset: offset - FluentFeed.PAGE_SIZE)
            return
        }
        let size = min(FluentFeed.PAGE_SIZE,to - (page * FluentFeed.PAGE_SIZE))
        if size > 0 {
            let _ = session.clientService.feed.list(page, size: size).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < FluentFeed.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to, obs)
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
    
    public func blockingStream(limit: Int = Int.max) throws -> [Feed] {
        return try self.list(page: 0, size: limit).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max) throws -> Observable<Feed> {
        return self.list(page: 0, size: limit)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [Feed] {
        return try self.list(page: page, size: size).toBlocking().toArray()
    }

    public func list(page: Int = 0, size: Int = 10) -> Observable<Feed> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > FluentFeed.PAGE_SIZE {
                var offset = page*size
                let page = offset / FluentFeed.PAGE_SIZE
                offset -= page * FluentFeed.PAGE_SIZE
                self.stream(page, to, obs, offset: offset)
            } else {
                self.stream(page, to, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingSendWallPost(_ feedPost: FeedPost) throws -> Feed? {
        return try self.blockingCreate(feedPost)
    }
    
    public func sendWallPost(_ feedPost: FeedPost) -> Observable<Feed> {
        return self.create(feedPost)
    }
    
    public func blockingGet(_ id: Int64) throws -> Feed? {
        return try self.get(id).toBlocking().first()
    }
    
    public func get(_ id: Int64) -> Observable<Feed> {
        return session.clientService.feed.get(id)
    }

    public func blockingCreate(_ feedPost: FeedPost) throws -> Feed? {
        return try self.sendWallPost(feedPost).toBlocking().last()
    }
    
    public func create(_ feedPost: FeedPost) -> Observable<Feed> {
        return Observable.create {
            obs in
            let _ = self.session.account.get().subscribe {
                e in
                if let e = e.element {
                    let _ = e.sendWallPost(feedPost).subscribe {
                        e in
                        if let e = e.element {
                            obs.onNext(e)
                        } else if let e = e.error {
                            obs.onError(e)
                        }
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

    public func blockingSearch(_ search: Search, page: Int = 0, size: Int = 10) throws -> SearchResultValue<Feed>? {
        return try self.search(search, page: page, size: size).toBlocking().first()
    }
    
    public func search(_ search: Search, page: Int = 0, size: Int = 10) -> Observable<SearchResultValue<Feed>> {
        return Observable.create {
            obs in
            if size > 0 {
                let _ = self.session.clientService.search.get(page, size: size, params: search.toQueryParams()).subscribe {
                    e in
                    if let e = e.element?.resultsByType?.feeds {
                        obs.onNext(e)
                    } else if let e = e.error {
                        obs.onError(e)
                    } else {
                        let e = SearchResultValue<Feed>()
                        e.matchedCount = 0
                        obs.onNext(e)
                    }
                    obs.onCompleted()
                }
            } else {
                let e = SearchResultValue<Feed>()
                e.matchedCount = 0
                obs.onNext(e)
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public class Search: ISearch {
        
        public class Builder {
            private var user = User()
            private var mTextToSearch: String? = nil
            private var mSortOrder: SortOrder? = nil
            private var mLocationMaximumDistance: Double? = nil
            private var mMatchAll: Bool? = nil
            private var mStartsWith: Bool? = true
            private var mEndsWith: Bool? = true

            public init() {}
            
            public func setTextToSearch(_ textToSearch: String) -> Builder {
                self.mTextToSearch = textToSearch
                return self
            }
            
            public func setOrder(_ sortOrder: SortOrder) -> Builder {
                self.mSortOrder = sortOrder
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
            
            public func setOwnerLivingLocationMaximumDistanceInMeters(_ maximumDistance: Double) -> Builder {
                self.mLocationMaximumDistance = maximumDistance
                return self
            }
            
            public func setOwnerLivingLocationMaximumDistanceInKilometers(_ maximumDistance: Double) -> Builder {
                self.mLocationMaximumDistance = maximumDistance * 1000
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
                return Search(SearchQuery(user: user, q: mTextToSearch, name: nil, content: nil, maximumDistanceInMeters: mLocationMaximumDistance, sortOrder: mSortOrder, startDate: nil, endDate: nil, dateField: nil, matchAll: mMatchAll, startsWith: mStartsWith, endsWith: mEndsWith))
            }
        }
        
        override func toQueryParams() -> [String: String] {
            var m = super.toQueryParams()
            m["type"] = "FEED"
            return m
        }
    }
}
