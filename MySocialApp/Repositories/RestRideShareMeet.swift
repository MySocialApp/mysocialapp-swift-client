import Foundation
import RxSwift

class RestRideShareMeet: RestBase<RideShareMeet, RideShareMeet> {
    func list(forRideId: String) -> Observable<JSONableArray<RideShareMeet>> {
        return super.list("/rideshare/ride/\(forRideId)/meet")
    }
}
