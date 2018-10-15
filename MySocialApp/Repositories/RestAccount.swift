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
    
    func postPhoto(_ image: UIImage, onComplete: @escaping (Base?)->Void) {
        var data: [DataToUpload] = []
        let url = "/account/profile/photo"
        if let d = ImageUtils.toData(image) {
            data.append(DataToUpload(data: d, name: "file", fileName: "image", mimeType: "image/jpeg"))
        }
        if data.count > 0 {
            super.uploadRequest(url, data: data, completionHandler: onComplete)
        } else {
            onComplete(nil)
        }
    }

    func delete(_ password: String) -> Observable<User> {
        let user = User()
        user.password = password
        return super.post("/account/delete", input: user)
    }
}
