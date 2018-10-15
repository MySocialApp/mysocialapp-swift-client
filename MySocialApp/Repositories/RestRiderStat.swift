import Foundation
import RxSwift

class RestRiderStat: RestBase<UserStat, UserStat> {
    
    func get(_ id: Int64) -> Observable<UserStat> {
        return super.get("/user/\(id)/stat")
    }
}
