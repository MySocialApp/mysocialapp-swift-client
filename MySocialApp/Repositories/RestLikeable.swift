import Foundation
import RxSwift

class RestLikeable: RestBase<Base, Like> {
    
    private func getBaseUrl(_ likeable: Base) -> String? {
        if let id = likeable.getIdStr() {
            switch likeable {
                case is Display:
                    return "/display/\(id)"
                case is Photo:
                    return "/photo/\(id)"
                case is Status:
                    return "/status/\(id)"
                default:
                    return "/feed/\(id)"
            }
        }
        return nil
    }
    
    func get(_ likeable: Base) -> Observable<JSONableArray<Like>> {
        if let base = self.getBaseUrl(likeable) {
            return super.list("\(base)/like")
        } else {
            return listEmpty()
        }
    }
    
    func post(_ likeable: Base) -> Observable<Like> {
        if let base = self.getBaseUrl(likeable) {
            return super.post("\(base)/like", input: nil)
        } else {
            return getEmpty()
        }
    }
    
    func delete(_ likeable: Base) -> Observable<Bool> {
        if let base = self.getBaseUrl(likeable) {
            return super.delete("\(base)/like")
        } else {
            return boolEmpty()
        }
    }
}
