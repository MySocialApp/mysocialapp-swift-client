import Foundation
import RxSwift

class RestReset: RestBase<Reset, Reset> {

    func post(_ resetModel: Reset) -> Observable<Reset> {
        return super.post("/reset", input: resetModel)
    }

}
