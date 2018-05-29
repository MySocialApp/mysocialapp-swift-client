import Foundation
import RxSwift

class RestRideIdGenerator: RestBase<RideIdGenerator, RideIdGenerator> {
    func get() -> Observable<RideIdGenerator> {
        return super.get("/ride/id/generator")
    }
}
