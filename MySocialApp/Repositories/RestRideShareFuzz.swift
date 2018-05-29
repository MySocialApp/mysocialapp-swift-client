import Foundation
import RxSwift

class RestRideShareFuzz: RestBase<RideShareFuzz, RideShareFuzz> {
    func get() -> Observable<RideShareFuzz> {
        return super.get("/rideshare/fuzz")
    }
    
    func post(_ fuzz: RideShareFuzz) -> Observable<RideShareFuzz> {
        return super.post("/rideshare/fuzz", input: fuzz)
    }
    
    func delete(_ fuzz: RideShareFuzz) -> Observable<Bool> {
        return super.delete("/rideshare/fuzz")
    }
}
