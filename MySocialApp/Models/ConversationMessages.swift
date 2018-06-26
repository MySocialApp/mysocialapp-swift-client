import Foundation
import RxSwift

public class ConversationMessages: JSONable {
    private static let PAGE_SIZE = 10
    
    var conversationId: Int64? = nil

    public var totalUnreads: Int?{
        get { return (super.getAttributeInstance("total_unreads") as! JSONableInt?)?.int }
        set(totalUnreads) { super.setIntAttribute(withName: "total_unreads", totalUnreads) }
    }
    public var samples: [ConversationMessage]? {
        get { return (super.getAttributeInstance("samples") as! JSONableArray<ConversationMessage>?)?.array }
        set(samples) { super.setArrayAttribute(withName: "samples", samples) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "total_unreads":
            return JSONableInt().initAttributes
        case "samples":
            return JSONableArray<ConversationMessage>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    internal func updateConversationId(_ id: Int64?) -> ConversationMessages {
        self.conversationId = id
        return self
    }

    private func stream(_ page: Int, _ to: Int, _ consume: Bool, _ obs: AnyObserver<ConversationMessage>, offset: Int = 0) {
        guard offset < ConversationMessages.PAGE_SIZE else {
            self.stream(page+1, to - ConversationMessages.PAGE_SIZE, consume, obs, offset: offset - ConversationMessages.PAGE_SIZE)
            return
        }
        if to > 0, let session = self.session {
            let _ = session.clientService.conversationMessage.list(page, size: min(ConversationMessages.PAGE_SIZE,to - (page * ConversationMessages.PAGE_SIZE)), forConversation: conversationId, andConsume: consume).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < ConversationMessages.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to - ConversationMessages.PAGE_SIZE, consume, obs)
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

    public func blockingStream(limit: Int = Int.max) throws -> [ConversationMessage] {
        return try stream(limit: limit).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max) -> Observable<ConversationMessage> {
        return list(page: 0, size: limit)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [ConversationMessage] {
        return try list(page: page, size: size).toBlocking().toArray()
    }
    
    public func list(page: Int = 0, size: Int = 10) -> Observable<ConversationMessage> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > ConversationMessages.PAGE_SIZE {
                var offset = page*size
                let page = offset / ConversationMessages.PAGE_SIZE
                offset -= page * ConversationMessages.PAGE_SIZE
                self.stream(page, to, false, obs, offset: offset)
            } else {
                self.stream(page, to, false, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingStreamAndConsume(limit: Int = Int.max) throws -> [ConversationMessage] {
        return try stream(limit: limit).toBlocking().toArray()
    }
    
    public func streamAndConsume(limit: Int = Int.max) -> Observable<ConversationMessage> {
        return list(page: 0, size: limit)
    }
    
    public func blockingListAndConsume(page: Int = 0, size: Int = 10) throws -> [ConversationMessage] {
        return try list(page: page, size: size).toBlocking().toArray()
    }
    
    public func listAndConsume(page: Int = 0, size: Int = 10) -> Observable<ConversationMessage> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > ConversationMessages.PAGE_SIZE {
                var offset = page*size
                let page = offset / ConversationMessages.PAGE_SIZE
                offset -= page * ConversationMessages.PAGE_SIZE
                self.stream(page, to, true, obs, offset: offset)
            } else {
                self.stream(page, to, true, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
}
