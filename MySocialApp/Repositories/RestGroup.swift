import Foundation
import RxSwift

class RestGroup: RestBase<Group, Group> {
    
    func list(_ page: Int, parameters: [String:String] = [:]) -> Observable<JSONableArray<Group>> {
        var params: [String:AnyObject] = [:]
        for k in parameters.keys {
            params[k] = parameters[k] as AnyObject
        }
        params["page"] = page as AnyObject
        return super.list("/group", params: params)
    }
    
    func get(_ id: Int64, limited: Bool = true) -> Observable<Group> {
        return super.get("/group/\(id)?limited=\(limited)")
    }

    func list(forUser user: User, page: Int = 0) -> Observable<JSONableArray<Group>> {
        if let id = user.id {
            return super.list("/user/\(id)/group", params: ["page":page as AnyObject])
        } else {
            return self.listEmpty()
        }
    }    
    
    func post(_ group: Group) -> Observable<Group> {
        return super.post("/group", input: group)
    }
    
    func update(_ group: Group) -> Observable<Group> {
        if let id = group.id {
            return super.update("/group/\(id)", input: group)
        }
        return super.getEmpty()
    }
}
