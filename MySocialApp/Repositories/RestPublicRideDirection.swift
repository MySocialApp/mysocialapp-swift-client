import Foundation
import RxSwift

class RestPublicRideDirection: RestBase<JSONableArray<RideLocation>, RideDirection> {
    func post(_ locations: JSONableArray<RideLocation>, parameters: [String:AnyObject] = [:]) -> Observable<RideDirection> {
        return super.post("/public/ride/direction", input: JSONableArray<RideLocation>(locations.array.map { $0.safeToSend() }), params: parameters)
    }
}
