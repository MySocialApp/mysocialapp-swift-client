import Foundation
import RxSwift

class RestPointOfInterestReview: RestBase<PointOfInterestReview, PointOfInterestReview> {
    func list(_ id: String) -> Observable<JSONableArray<PointOfInterestReview>> {
        return super.list("/poi/\(id)/review")
    }
    
    func post(_ review: PointOfInterestReview, forPoi: String) -> Observable<PointOfInterestReview> {
        return super.post("/poi/\(forPoi)/review", input: review)
    }
}
