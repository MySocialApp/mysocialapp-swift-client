import Foundation
import RxSwift

class RestRideLocation: RestBase<JSONableArray<RideLocation>,JSONableArray<RideLocation>> {
    func list(forRideId rideId: Int64) -> Observable<JSONableArray<RideLocation>> {
        return super.get("/ride/\(rideId)/location/detail", params: [:])
    }
    
    func post(forRideId rideId: Int64, _ locations: JSONableArray<RideLocation>, parameters: [String:AnyObject] = [:]) -> Observable<JSONableArray<RideLocation>> {
        return super.post("/ride/\(rideId)/location", input: JSONableArray<RideLocation>(locations.array.map { $0.safeToSend() }), params: parameters)
    }
    
    func importFile(_ data: Data, parameters: [String:AnyObject] = [:], onComplete: @escaping (JSONableArray<RideLocation>?)->Void) {
        var d: [DataToUpload] = []
        d.append(DataToUpload(data: data, name: "file", fileName: "fichier", mimeType: "application/xml"))
        if data.count > 0 {
            super.uploadRequest("/ride/reader/file", data: d, completionHandler: onComplete)
        } else {
            onComplete(nil)
        }
    }
}
