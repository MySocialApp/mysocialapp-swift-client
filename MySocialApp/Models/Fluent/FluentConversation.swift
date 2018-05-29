import Foundation
import RxSwift

class FluentConversation {
    private static let PAGE_SIZE = 10

    var session: Session
    
    public init(_ session:  Session) {
        self.session = session
    }
    
    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<Conversation>) {
        if to > 0 {
            let _ = session.clientService.conversation.list(page, size: min(FluentConversation.PAGE_SIZE,to - (page * FluentConversation.PAGE_SIZE))).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < FluentConversation.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to - FluentConversation.PAGE_SIZE, obs)
                    }
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }
    
    public func blockingStream(limit: Int = Int.max) throws -> [Conversation] {
        return try self.list(page: 0, size: limit).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max) throws -> Observable<Conversation> {
        return self.list(page: 0, size: limit)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [Conversation] {
        return try self.list(page: page, size: size).toBlocking().toArray()
    }

    public func list(page: Int = 0, size: Int = 10) -> Observable<Conversation> {
        return Observable.create {
            obs in
            self.stream(page, size, obs)
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }

    func blockingGet(_ id: Int64) throws -> Conversation? {
        return try self.get(id).toBlocking().first()
    }
    
    func get(_ id: Int64) -> Observable<Conversation> {
        return session.clientService.conversation.get(id)
    }
    
    func blockingCreate(_ conversation: Conversation) throws -> Conversation? {
        return try self.create(conversation).toBlocking().first()
    }
    
    func create(_ conversation: Conversation) -> Observable<Conversation> {
        return session.clientService.conversation.post(conversation)
    }
}
