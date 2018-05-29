import Foundation
import RxSwift

class RestDeviceLocation: RestBase<Location,Location> {
    func post(_ id: Int64, location: Location) -> Observable<Location> {
        return super.post("/device/location/\(id)", input: location)
    }
}
