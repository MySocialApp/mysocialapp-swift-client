import Foundation
import RxSwift

class RestURLTag: RestBase<URLTag, URLTag> {    
    func list(_ page: Int, query: String? = nil, contentType: String? = nil) -> Observable<JSONableArray<URLTag>> {
        var params = ["page": page as AnyObject]
        if let q = query {
            params["q"] = q as AnyObject
        }
        if let c = contentType {
            params["content_type"] = c as AnyObject
        }
        return super.list("/urltag", params: params)
    }
}
