import Foundation
import RxSwift

class RestConversation: RestBase<Conversation, Conversation> {
    
    func list(_ page: Int, size: Int = 10) -> Observable<JSONableArray<Conversation>> {
        return super.list("/conversation", params: ["messageSamples": 1 as AnyObject, "page": page as AnyObject, "size": size as AnyObject])
    }
    
    func listNoSample(_ page: Int, size: Int = 10) -> Observable<JSONableArray<Conversation>> {
        return super.list("/conversation", params: ["messageSamples": 0 as AnyObject, "page": page as AnyObject, "size": size as AnyObject])
    }
    
    func get(_ id: Int64) -> Observable<Conversation> {
        return super.get("/conversation/\(id)")
    }
    
    func post(_ conversation: Conversation) -> Observable<Conversation> {
        return super.post("/conversation", input: conversation)
    }
    
    func update(_ conversation: Conversation, forConversation: Int64?) -> Observable<Conversation> {
        if let id = forConversation {
            return super.update("/conversation/\(id)", input: conversation)
        }
        return super.getEmpty()
    }
    
    func delete(_ id: Int64) -> Observable<Bool> {
        return super.delete("/conversation/\(id)", params: [:])
    }
}
