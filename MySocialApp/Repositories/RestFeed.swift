import Foundation
import RxSwift

class RestFeed: RestBase<Feed, Feed> {
    
    func list(_ page: Int, size: Int = 10, forAlgorithm: AnyObject? = nil, forUser: User? = nil, forGroup: Group? = nil, forEvent: Event? = nil, forRide: Ride? = nil, withParams: [String:AnyObject]? = nil) -> Observable<JSONableArray<Feed>> {
        var params: [String:AnyObject] = ["page": String(page) as AnyObject, "size": String(size) as AnyObject]
        if let p = withParams {
            for k in p.keys {
                params[k] = p[k]
            }
        }
        if let algorithm = forAlgorithm {
            return super.postForList("/feed", input: algorithm, params: params)
        } else if let id = forUser?.id {
            return super.list("/user/\(id)/wall", params: params)
        } else if let id = forGroup?.id {
            return super.list("/group/\(id)/wall", params: params)
        } else if let id = forEvent?.id {
            return super.list("/event/\(id)/wall", params: params)
        } else if let id = forRide?.id {
            return super.list("/ride/\(id)/wall", params: params)
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
    
    func post(_ group: Group, image: UIImage, forCover cover: Bool, onComplete: @escaping (Feed?)->Void) {
        if let id = group.id {
            var data: [DataToUpload] = []
            var url = "/group/\(id)/profile/"
            if cover {
                url += "cover"
            }
            url += "photo"
            if let d = ImageUtils.toData(image) {
                data.append(DataToUpload(data: d, name: "file", fileName: "image", mimeType: "image/jpeg"))
            }
            if data.count > 0 {
                super.uploadRequest(url, data: data, completionHandler: onComplete)
            } else {
                onComplete(nil)
            }
        } else {
            onComplete(nil)
        }
    }
    
    func post(_ event: Event, image: UIImage, onComplete: @escaping (Feed?)->Void) {
        if let id = event.id {
            var data: [DataToUpload] = []
            let url = "/event/\(id)/cover"
            if let d = ImageUtils.toData(image) {
                data.append(DataToUpload(data: d, name: "file", fileName: "image", mimeType: "image/jpeg"))
            }
            if data.count > 0 {
                super.uploadRequest(url, data: data, completionHandler: onComplete)
            } else {
                onComplete(nil)
            }
        } else {
            onComplete(nil)
        }
    }
}
