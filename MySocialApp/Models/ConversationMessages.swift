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

    private func stream(_ page: Int, _ to: Int, _ consume: Bool, _ obs: AnyObserver<ConversationMessage>) {
        if to > 0, let session = self.session {
            let _ = session.clientService.conversationMessage.list(page, size: min(ConversationMessages.PAGE_SIZE,to - (page * ConversationMessages.PAGE_SIZE)), forConversation: conversationId, andConsume: consume).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < ConversationMessages.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to - ConversationMessages.PAGE_SIZE, consume, obs)
                    }
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
            self.stream(0, Int.max, false, obs)
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
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
            self.stream(0, Int.max, true, obs)
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
}
