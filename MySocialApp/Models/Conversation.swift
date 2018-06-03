import Foundation
import RxSwift

class Conversation: Base {

    var name: String?{
        get { return (super.getAttributeInstance("name") as! JSONableString?)?.string }
        set(name) { super.setStringAttribute(withName: "name", name) }
    }
    var messages: ConversationMessages? {
        get {
            return (super.getAttributeInstance("messages") as? ConversationMessages)?.updateConversationId(id)
        }
        set(messages) { super.setAttribute(withName: "messages", messages) }
    }
    var members: [User]? {
        get { return (self.getAttributeInstance("members") as! JSONableArray<User>?)?.array }
        set(members) { self.setArrayAttribute(withName: "members", members) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "name":
            return JSONableString().initAttributes
        case "messages":
            return ConversationMessages().initAttributes
        case "members":
            return JSONableArray<User>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    func blockingSendMessage(_ message: ConversationMessagePost) throws -> ConversationMessage? {
        return try sendMessage(message).toBlocking().first()
    }
    
    func sendMessage(_ message: ConversationMessagePost) -> Observable<ConversationMessage> {
        if let s = session, let id = self.id {
            if let i = message.photo {
                return Observable.create {
                    obs in
                    s.clientService.conversationMessage.post(message.conversationMessage, forConversation: id, withImage: i) {
                        e in
                        if let e = e as? ConversationMessage {
                            obs.onNext(e)
                        } else {
                            obs.onCompleted()
                        }
                    }
                    return Disposables.create()
                    }.observeOn(MainScheduler.instance)
                    .subscribeOn(MainScheduler.instance)
            } else {
                return s.clientService.conversationMessage.post(message.conversationMessage, forConversation: id)
            }
        } else {
                return Observable.create {
                    obs in
                    let e = RestError()
                    e.setStringAttribute(withName: "message", "No session associated with this entity")
                    obs.onError(e)
                    return Disposables.create()
                    }.observeOn(MainScheduler.instance)
                    .subscribeOn(MainScheduler.instance)
        }
    }
    
    func blockingKickMember(_ user: User) throws -> User? {
        return try kickMember(user).toBlocking().first()
    }
    
    func kickMember(_ user: User) -> Observable<User> {
        return Observable.create {
            obs in
            self.members = self.members?.filter { $0.id != user.id }
            let _ = self.save().subscribe {
                e in
                obs.onNext(user)
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
        .subscribeOn(MainScheduler.instance)
    }
    
    func blockingAddMember(_ user: User) throws -> User? {
        return try addMember(user).toBlocking().first()
    }
    
    func addMember(_ user: User) -> Observable<User> {
        return Observable.create {
            obs in
            var members = [user]
            if let m = self.members {
                members.append(contentsOf: m)
            }
            self.members = members
            let _ = self.save().subscribe {
                e in
                obs.onNext(user)
            }
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func blockingDelete() throws -> Bool? {
        return try delete().toBlocking().first()
    }
    
    override func delete() -> Observable<Bool> {
        if let s = session, let id = self.id {
            return s.clientService.conversation.delete(id)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func blockingSave() throws -> Conversation? {
        return try save().toBlocking().first()
    }
    
    func save() -> Observable<Conversation> {
        if let s = session {
            if let id = self.id {
                return s.clientService.conversation.update(self, forConversation: id)
            } else {
                return s.clientService.conversation.post(self)
            }
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
        }
    }
    
    func blockingQuit() throws -> Bool? {
        return try self.blockingDelete()
    }
    
    func quit() -> Observable<Bool> {
        return self.delete()
    }
    
    class Builder {
        private var mName: String? = nil
        private var mMembers: [User] = []
        
        func setName(_ name: String) -> Builder {
            self.mName = name
            return self
        }
        
        func addMember(member: User) -> Builder {
            self.mMembers.append(member)
            return self
        }
        
        func addMembers(members: [User]) -> Builder {
            self.mMembers.append(contentsOf: members)
            return self
        }
        
        func setMembers(members: [User]) -> Builder {
            self.mMembers = members
            return self
        }
        
        func build() -> Conversation {
            let c = Conversation()
            c.name = mName
            c.members = mMembers
            return c
        }
    }
}
