import Foundation
import RxSwift

class RestStatus: RestBase<Status,Status> {
    func delete(_ id: Int64) -> Observable<Bool> {
        return super.delete("/status/\(id)")
    }
    
    func post(_ status: Status) -> Observable<Status> {
        return super.post("/status", input: status)
    }
}
