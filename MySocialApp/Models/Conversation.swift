import Foundation
import RxSwift

public class Conversation: Base {

    public var name: String?{
        get { return (super.getAttributeInstance("name") as! JSONableString?)?.string }
        set(name) { super.setStringAttribute(withName: "name", name) }
    }
    public var messages: ConversationMessages? {
        get {
            return (super.getAttributeInstance("messages") as? ConversationMessages)?.updateConversationId(id)
        }
        set(messages) { super.setAttribute(withName: "messages", messages) }
    }
    public var members: [User]? {
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
    
    public func blockingSendMessage(_ message: ConversationMessagePost) throws -> ConversationMessage? {
        return try sendMessage(message).toBlocking().first()
    }
    
    public func sendMessage(_ message: ConversationMessagePost) -> Observable<ConversationMessage> {
        if let s = session, let id = self.id {
            if let i = message.photo {
                return Observable.create {
                    obs in
                    s.clientService.conversationMessage.post(message.conversationMessage, forConversation: id, withImage: i) {
                        e in
                        if let e = e as? ConversationMessage {
                            obs.onNext(e)
                        }
                        obs.onCompleted()
                    }
                    return Disposables.create()
                    }.observeOn(self.scheduler())
                    .subscribeOn(self.scheduler())
            } else {
                return s.clientService.conversationMessage.post(message.conversationMessage, forConversation: id)
            }
        } else {
                return Observable.create {
                    obs in
                    let e = MySocialAppException()
                    e.setStringAttribute(withName: "message", "No session associated with this entity")
                    obs.onError(e)
                    return Disposables.create()
                    }.observeOn(self.scheduler())
                    .subscribeOn(self.scheduler())
        }
    }
    
    public func blockingKickMember(_ user: User) throws -> User? {
        return try kickMember(user).toBlocking().first()
    }
    
    public func kickMember(_ user: User) -> Observable<User> {
        return Observable.create {
            obs in
            self.members = self.members?.filter { $0.id != user.id }
            let _ = self.save().subscribe {
                e in
                if let e = e.element {
                    obs.onNext(user)
                } else if let error = e.error {
                    obs.onError(error)
                }
                obs.onCompleted()
            }
            return Disposables.create()
        }.observeOn(self.scheduler())
        .subscribeOn(self.scheduler())
    }
    
    public func blockingAddMember(_ user: User) throws -> User? {
        return try addMember(user).toBlocking().first()
    }
    
    public func addMember(_ user: User) -> Observable<User> {
        return Observable.create {
            obs in
            var members = [user]
            if let m = self.members {
                members.append(contentsOf: m)
            }
            self.members = members
            let _ = self.save().subscribe {
                e in
                if let e = e.element {
                    obs.onNext(user)
                } else if let error = e.error {
                    obs.onError(error)
                }
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingDelete() throws -> Bool? {
        return try delete().toBlocking().first()
    }
    
    public override func delete() -> Observable<Bool> {
        if let s = session, let id = self.id {
            return s.clientService.conversation.delete(id)
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
    
    public func blockingSave() throws -> Conversation? {
        return try save().toBlocking().first()
    }
    
    public func save() -> Observable<Conversation> {
        if let s = session {
            if let _ = self.id {
                return s.clientService.conversation.update(self, forConversation: id)
            } else {
                return s.clientService.conversation.post(self)
            }
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
        }
    }
    
    public func blockingQuit() throws -> Bool? {
        return try self.blockingDelete()
    }
    
    public func quit() -> Observable<Bool> {
        return self.delete()
    }
    
    public class Builder {
        private var mName: String? = nil
        private var mMembers: [User] = []
        
        public init() {}
        
        public func setName(_ name: String) -> Builder {
            self.mName = name
            return self
        }
        
        public func addMember(member: User) -> Builder {
            self.mMembers.append(member)
            return self
        }
        
        public func addMembers(members: [User]) -> Builder {
            self.mMembers.append(contentsOf: members)
            return self
        }
        
        public func setMembers(members: [User]) -> Builder {
            self.mMembers = members
            return self
        }
        
        public func build() -> Conversation {
            let c = Conversation()
            c.name = mName
            c.members = mMembers
            return c
        }
    }
}
