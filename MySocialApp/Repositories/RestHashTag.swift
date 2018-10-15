import Foundation
import RxSwift

class RestHashTag: RestBase<HashTag, HashTag> {
    func list(_ page: Int, size: Int? = nil, query: String? = nil) -> Observable<JSONableArray<HashTag>> {
        var params: [String:AnyObject] = [:]
        if let q = query {
            params["q"] = q as AnyObject
        }
        if let s = size {
            params["size"] = s as AnyObject
        }
        params["page"] = page as AnyObject
        return super.list("/hashtag", params: params)
    }
}
