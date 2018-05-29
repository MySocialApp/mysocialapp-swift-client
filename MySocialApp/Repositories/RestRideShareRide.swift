import Foundation
import RxSwift

class RestRideShareRide: RestBase<RideShareRide, RideShareRide> {
    
    func list() -> Observable<JSONableArray<RideShareRide>> {
        return super.list("/rideshare/ride")
    }
    
    func get(_ rideId: String) -> Observable<RideShareRide> {
        return super.get("/rideshare/ride/\(rideId)")
    }
    
    func delete(_ rideShareRide: RideShareRide) -> Observable<Bool> {
        if let id = rideShareRide.rideId {
            return super.delete("/rideshare/ride/\(id)")
        }
        return super.boolEmpty()
    }
    
    func put(_ rideShareRide: RideShareRide) -> Observable<RideShareRide> {
        if let id = rideShareRide.rideId {
            return super.update("/rideshare/ride/\(id)", input: rideShareRide)
        }
        return super.getEmpty()
    }

}
