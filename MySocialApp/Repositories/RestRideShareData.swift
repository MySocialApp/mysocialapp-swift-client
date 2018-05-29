import Foundation
import RxSwift

class RestRideShareData: RestBase<RideShareData, RideShareData> {
    func get(_ trackingId: String, startTimestamp: Int64 = 0) -> Observable<JSONableArray<RideShareData>> {
        return super.list("/rideshare/data/\(trackingId)", params: ["start_timestamp": "\(startTimestamp)" as AnyObject])
    }
    func post(_ data: RideShareData) -> Observable<RideShareData> {
        return super.post("/rideshare/data", input: data)
    }
}
