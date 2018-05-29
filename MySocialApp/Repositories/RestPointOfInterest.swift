import Foundation
import RxSwift

class RestPointOfInterest: RestBase<PointOfInterest,PointOfInterest> {
    func list(lowerLatitude: Double? = nil, lowerLongitude: Double? = nil, upperLatitude: Double? = nil, upperLongitude: Double? = nil, parameters: [String:String] = [:]) -> Observable<JSONableArray<PointOfInterest>> {
        var params: [String:AnyObject] = [:]
        for k in parameters.keys {
            params[k] = parameters[k] as AnyObject
        }
        if let l = lowerLatitude {
            params["lower_latitude"] = l as AnyObject
        }
        if let l = lowerLongitude {
            params["lower_longitude"] = l as AnyObject
        }
        if let l = upperLatitude {
            params["upper_latitude"] = l as AnyObject
        }
        if let l = upperLongitude {
            params["upper_longitude"] = l as AnyObject
        }
        return super.list("/poi", params: params)
    }
    
    func list (_ page: Int, forRider: User?) -> Observable<JSONableArray<PointOfInterest>> {
        if let id = forRider?.id {
            return super.list("/user/\(id)/poi", params: ["page":page as AnyObject])
        }
        return self.list()
    }
    
    func get(_ id: String) -> Observable<PointOfInterest> {
        return super.get("/poi/\(id)")
    }
    
    func getDetails(_ id: String) -> Observable<PointOfInterest> {
        return super.get("/poi/\(id)/detail")
    }
    
    func post(_ pointOfInterest: PointOfInterest) -> Observable<PointOfInterest> {
        return super.post("/poi", input: pointOfInterest)
    }
    
    func update(_ id: String, pointOfInterest: PointOfInterest) -> Observable<PointOfInterest> {
        return super.update("/poi/\(id)", input: pointOfInterest)
    }
    
    func delete(_ id: String) -> Observable<Bool> {
        return super.delete("/poi/\(id)")
    }
    
    func post(forTarget target: PointOfInterest, message: String?, image: UIImage, onComplete: @escaping (Base?)->Void) {
        if let id = target.idStr {
            var data: [DataToUpload] = []
            let url = "/poi/\(id)/photo"
            if let d = ImageUtils.toData(image) {
                data.append(DataToUpload(data: d, name: "file", fileName: "image", mimeType: "image/jpeg"))
            }
            if let d = message?.data(using: .utf8) {
                data.append(DataToUpload(data: d, name: "name", fileName: nil, mimeType: "multipart/form-data"))
            }
            if let d = "true".data(using: .utf8) {
                data.append(DataToUpload(data: d, name: "is_public", fileName: nil, mimeType: "multipart/form-data"))
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
