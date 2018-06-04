import Foundation
import RxSwift

class RestUser: RestBase<User, User> {
    
    func list(_ page: Int, size: Int? = nil, friendsWith rider: User? = nil, latitude: Double? = nil, longitude: Double? = nil, fullName: String? = nil, parameters: [String:String] = [:]) -> Observable<JSONableArray<User>> {
        var params: [String:AnyObject] = [:]
        for k in parameters.keys {
            params[k] = parameters[k] as AnyObject
        }
        params["page"] = page as AnyObject
        if let s = size {
            params["size"] = s as AnyObject
        }
        if let l = latitude {
            params["latitude"] = l as AnyObject
        }
        if let l = longitude {
            params["longitude"] = l as AnyObject
        }
        if let n = fullName {
            params["full_name"] = n as AnyObject
        }
        if let r = rider, let id = r.id {
            return super.list("/user/\(id)/friend", params: params)
        }
        // TODO : version géoloc de la recherche
        return super.list("/user", params: params)
    }
    
    func listOutgoingRequests() -> Observable<JSONableArray<User>> {
        return super.list("/friend/request/outgoing")
    }
    
    func listActive() -> Observable<JSONableArray<User>> {
        return super.list("/user/active")
    }
    
    func noMoreFriend(_ rider: User) -> Observable<Bool> {
        if let id = rider.id {
            return super.delete("/user/\(id)/friend")
        } else {
            return super.boolEmpty()
        }
    }
    
    func get(_ id: Int64) -> Observable<User> {
        return super.get("/user/\(id)")
    }
    
    func getByExternalId(_ id: String) -> Observable<User> {
        return super.get("/user/external/\(id)")
    }
    
    func acceptAsFriend(_ rider: User) -> Observable<User> {
        if let id = rider.id {
            return super.post("/user/\(id)/friend", input: nil)
        } else {
            return super.getEmpty()
        }
    }
    
    func refuseAsFriend(_ rider: User) -> Observable<Bool> {
        if let id = rider.id {
            return super.delete("/user/\(id)/friend")
        } else {
            return super.boolEmpty()
        }
    }
    
    func requestAsFriend(_ rider: User) -> Observable<User> {
        if let id = rider.id {
            return super.post("/user/\(id)/friend", input: nil)
        } else {
            return super.getEmpty()
        }
    }
    
    func cancelRequestAsFriend(_ rider: User) -> Observable<Bool> {
        if let id = rider.id {
            return super.delete("/user/\(id)/friend")
        } else {
            return super.boolEmpty()
        }
    }
    
    func requestedToBeFriends(_ page: Int) -> Observable<JSONableArray<User>> {
        return super.list("/friend/request/incoming", params: ["page": page as AnyObject])
    }
    
    func requestedAsFriends(_ page: Int) -> Observable<JSONableArray<User>> {
        return super.list("/friend/request/outgoing", params: ["page": page as AnyObject])
    }
    
    func join(group: Group) -> Observable<User> {
        if let id = group.id {
            return super.post("/group/\(id)/member", input: nil)
        } else {
            return super.getEmpty()
        }
    }
    
    func unjoin(group: Group) -> Observable<Bool> {
        if let id = group.id {
            return super.delete("/group/\(id)/member")
        } else {
            return super.boolEmpty()
        }
    }
    
    func join(event: Event) -> Observable<User> {
        if let id = event.id {
            return super.post("/event/\(id)/member", input: nil)
        } else {
            return super.getEmpty()
        }
    }
    
    func unjoin(event: Event) -> Observable<Bool> {
        if let id = event.id {
            return super.delete("/event/\(id)/member")
        } else {
            return super.boolEmpty()
        }
    }
}
