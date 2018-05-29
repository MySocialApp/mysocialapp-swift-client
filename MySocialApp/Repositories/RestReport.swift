import Foundation
import RxSwift

class RestReport: RestBase<Base,Base> {
    func post(_ id: Int64) -> Observable<Base> {
        return super.post("/feed/\(id)/abuse", input: nil)
    }
}

