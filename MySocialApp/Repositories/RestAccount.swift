import Foundation
import RxSwift

class RestAccount: RestBase<User, User> {

    func get() -> Observable<User> {
        return super.get("/account")
    }
    
    func create(_ user: User) -> Observable<User> {
        return super.post("/register", input: user)
    }
    
    func update(_ user: User) -> Observable<User> {
        return super.update("/account", input: user)
    }
    
    func postPhoto(_ image: Data, withMimeType mimeType: String = "image/jpeg", onComplete: @escaping (Base?)->Void) {
        var data: [DataToUpload] = []
        let url = "/account/profile/photo"
        data.append(DataToUpload(data: image, name: "file", fileName: "image", mimeType: mimeType))
        super.uploadRequest(url, data: data, completionHandler: onComplete)
    }


}
