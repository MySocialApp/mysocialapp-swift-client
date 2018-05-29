import Foundation
import RxSwift

class RestRideShareMeetSetting: RestBase<RideShareMeetSetting, RideShareMeetSetting> {
    
    func get() -> Observable<RideShareMeetSetting> {
        return super.get("/rideshare/meet/setting")
    }
    
    func post(_ setting: RideShareMeetSetting) -> Observable<RideShareMeetSetting> {
        return super.post("/rideshare/meet/setting", input: setting)
    }
}
