import Foundation
import RxSwift

class RestRide: RestBase<Ride, Ride> {

    func list(_ page: Int, forRider rider: User? = nil, parameters: [String:String] = [:]) -> Observable<JSONableArray<Ride>> {
        var params: [String:AnyObject] = [:]
        for k in parameters.keys {
            if k == "name", let v = StringUtils.trimToNil(parameters[k]) {
                params[k] = "\(v)*" as AnyObject
            } else {
                params[k] = parameters[k] as AnyObject
            }
        }
        params["page"] = page as AnyObject
        if let r = rider, let id = r.id {
            return super.list("/user/\(id)/ride", params: params)
        } else {
            return super.list("/ride", params: params)
        }
    }

    func get(_ id: Int64) -> Observable<Ride> {
        return super.get("/ride/\(id)")
    }

    func post(_ ride: Ride) -> Observable<Ride> {
        return super.post("/ride", input: ride)
    }

    func update(_ id: Int64, ride: Ride) -> Observable<Ride> {
        return super.update("/ride/\(id)", input: ride)
    }

    func delete(_ id: Int64) -> Observable<Bool> {
        return super.delete("/ride/\(id)")
    }
    
    func list(forEvent event: Int64, page: Int = 0) -> Observable<JSONableArray<Ride>> {
        return super.list("/event/\(event)/ride", params: ["page": page as AnyObject])
    }
    
    func link(_ ride: Int64, toEvent event: Int64) -> Observable<Ride> {
        return super.post("/event/\(event)/ride/\(ride)", input: nil)
    }
    
    func unlink(_ ride: Int64, toEvent event: Int64) -> Observable<Bool> {
        return super.delete("/event/\(event)/ride/\(ride)")
    }

}
