import Foundation
import RxSwift

class RestReport: RestBase<Base,Base> {
    func post(_ id: Int64) -> Observable<Void> {
        return super.postVoid("/feed/\(id)/abuse", input: nil)
    }
}

