import Foundation
import RxSwift

class RestFeed: RestBase<Feed, Feed> {
    
    func list(_ page: Int, size: Int = 10, forRider: User? = nil, withParams: [String:AnyObject]? = nil) -> Observable<JSONableArray<Feed>> {
        var params: [String:AnyObject] = ["page": String(page) as AnyObject, "size": String(size) as AnyObject]
        if let p = withParams {
            for k in p.keys {
                params[k] = p[k]
            }
        }
        if let id = forRider?.id {
            return super.list("/user/\(id)/wall", params: params)
        }
        return super.list("/feed", params: params)
    }
    
    func get(_ id: Int64) -> Observable<Feed> {
        return super.get("/feed/\(id)")
    }
    

    func listPublic(_ page: Int, withParams: [String:AnyObject]? = nil) -> Observable<JSONableArray<Feed>> {
        var params: [String:AnyObject] = ["page": String(page) as AnyObject]
        if let p = withParams {
            for k in p.keys {
                params[k] = p[k]
            }
        }
        return super.list("/public/feed", params: params)
    }
    
    func consumeDisplay(_ id: String, uid: Int64, deviceId: String) -> Observable<Void> {
        return super.getVoid("/display/\(id)/consume", params: ["auth_uid": "\(uid)" as AnyObject, "device_id": deviceId as AnyObject])
    }

    func getAsList(_ id: Int64) -> Observable<JSONableArray<Feed>> {
        return super.getAsList("/feed/\(id)")
    }
    
    func stopFollow(_ id: Int64) -> Observable<Void> {
        return super.postVoid("/feed/\(id)/ignore", input: nil)
    }
    
    func delete(_ id: Int64, forRider: Int64? = nil) -> Observable<Bool> {
        if let rider = forRider {
            return super.delete("rider/\(rider)/wall/message/\(id)")
        }
        return super.delete("/feed/\(id)")
    }
}
