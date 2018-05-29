import Foundation
import RxSwift

class RestDevice: RestBase<Device, Device> {
    func list() -> Observable<JSONableArray<Device>> {
        return super.list("/device")
    }
    
    func get(_ id: String) -> Observable<Device> {
        return super.get("/device/\(id)")
    }
    
    func post(_ device: Device) -> Observable<Device> {
        return super.post("/device", input: device)
    }
    
    func delete(_ id: String) -> Observable<Bool> {
        return super.delete("/device/\(id)")
    }
}
