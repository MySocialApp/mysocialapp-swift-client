import Foundation
import RxSwift

class RestEvent: RestBase<Event, Event> {

    func list(_ page: Int, size: Int = 10, parameters: [String:String]? = nil) -> Observable<JSONableArray<Event>> {
        var params: [String:AnyObject] = [:]
        if let p = parameters {
            for k in p.keys {
                if k != "address" {
                    params[k] = p[k] as AnyObject
                }
            }
        }
        params["page"] = page as AnyObject
        params["size"] = size as AnyObject
        return super.list("/event", params: params)
    }

    func get(_ id: Int64) -> Observable<Event> {
        return super.get("/event/\(id)?limited=false")
    }

    func post(_ event: Event) -> Observable<Event> {
        return super.post("/event", input: event)
    }
    
    func list(forRide ride: Int64, page: Int = 0, size: Int = 10) -> Observable<JSONableArray<Event>> {
        return super.list("/ride/\(ride)/event", params: ["page": page as AnyObject, "size": size as AnyObject])
    }
    
    func list(forMember user: Int64, page: Int = 0, size: Int = 10, parameters: [String:String]? = nil) -> Observable<JSONableArray<Event>> {
        var params: [String:AnyObject] = [:]
        if let p = parameters {
            for k in p.keys {
                if k != "address" {
                    params[k] = p[k] as AnyObject
                }
            }
        }
        params["page"] = page as AnyObject
        params["size"] = size as AnyObject
        return super.list("/user/\(user)/event", params: params)
    }
    
    func link(_ event: Int64, toRide ride: Int64) -> Observable<Event> {
        return super.post("/ride/\(ride)/event/\(event)", input: nil)
    }
    
    func unlink(_ event: Int64, toRide ride: Int64) -> Observable<Bool> {
        return super.delete("/ride/\(ride)/event/\(event)")
    }

    func update(_ event: Event) -> Observable<Event> {
        if let id = event.id {
            return super.update("/event/\(id)", input: event)
        }
        return super.getEmpty()
    }

    func delete(_ id: Int64) -> Observable<Bool> {
        return super.delete("/event/\(id)")
    }
    
    func cancel(_ id: Int64) -> Observable<Event> {
        return super.post("/event/\(id)/cancel", input: nil)
    }

}
