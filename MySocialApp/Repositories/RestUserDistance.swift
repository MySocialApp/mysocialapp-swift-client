import Foundation
import RxSwift

class RestUserDistance: RestBase<UserDistance,UserDistance> {
    func get(_ id: Int64) -> Observable<UserDistance> {
        return super.get("/rideshare/user/\(id)/distance")
    }
}
