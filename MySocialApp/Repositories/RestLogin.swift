import Foundation
import RxSwift

class RestLogin: RestBase<Login, Login> {

    func login(_ loginModel: Login) -> Observable<Login> {
        return super.post("/login", input: loginModel)
    }
    
    func logout() -> Observable<Void> {
        return super.postVoid("/logout", input: nil)
    }

    func postFacebook(_ loginModel: Login) -> Observable<Login> {
        return super.post("/facebook/login", input: loginModel)
    }
}
