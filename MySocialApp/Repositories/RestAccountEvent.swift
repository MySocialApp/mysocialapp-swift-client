import Foundation
import RxSwift

class RestAccountEvent: RestBase<AccountEvent, AccountEvent> {
    func get() -> Observable<AccountEvent> {
        return super.get("/account/event")
    }
}
