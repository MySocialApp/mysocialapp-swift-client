import Foundation
import RxSwift

class RestSearch: RestBase<JSONable, SearchResults> {
    
    func get(_ page: Int, size: Int = 10, params: [String: String]) -> Observable<SearchResults> {
        var p: [String: AnyObject] = ["page": page as AnyObject, "size": size as AnyObject]
        let _ = params.map { p[$0] = $1 as AnyObject }
        return super.get("/search", params: p)
    }
    
}
