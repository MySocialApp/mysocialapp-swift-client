import Foundation
import RxSwift

public class FluentAccount {
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }
    
    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }

    public func blockingGet() throws -> User? {
        return try self.get().toBlocking().first()
    }
    
    public func get() -> Observable<User> {
        return self.session.clientService.account.get()
    }

    /**
     * Caution: your account will be completely erased and no more available.
     * This method delete all your data that belongs to this account.!!
     */
    public func blockingRequestForDeleteAccount(password: String) throws -> Bool? {
        return try requestForDeleteAccount(password: password).toBlocking().first()
    }
    
    /**
     * Caution: your account will be completely erased and no more available.
     * This method delete all your data that belongs to this account.!!
     */
    public func requestForDeleteAccount(password: String) -> Observable<Bool> {
        return session.clientService.login.deleteAccount(Login(username: "", password: password))
    }
    
    public func blockingGetAvailableCustomFields() throws -> [CustomField] {
        return try getAvailableCustomFields().toBlocking().toArray()
    }
    
    public func getAvailableCustomFields() -> Observable<CustomField> {
        return Observable.create {
            obs in
            let _ = self.session.clientService.customField.list(for: User()).subscribe {
                e in
                if let e = e.element?.array {
                    e.forEach { obs.onNext($0) }
                } else if let error = e.error {
                    obs.onError(error)
                }
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingChangeProfilePhoto(_ image: UIImage) throws -> Photo? {
        return try self.changeProfilePhoto(image).toBlocking().first()
    }
    
    public func changeProfilePhoto(_ image: UIImage) -> Observable<Photo> {
        return Observable.create {
            obs in
            self.session.clientService.photo.postPhoto(image, forModel: User()) {
                e in
                if let e = e {
                    obs.onNext(e)
                } else {
                    let e = MySocialAppException()
                    e.setStringAttribute(withName: "message", "An error occured while uploading profile photo")
                    obs.onError(e)
                }
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingChangeProfileCoverPhoto(_ image: UIImage) throws -> Photo? {
        return try self.changeProfileCoverPhoto(image).toBlocking().first()
    }
    
    public func changeProfileCoverPhoto(_ image: UIImage) -> Observable<Photo> {
        return Observable.create {
            obs in
            self.session.clientService.photo.postPhoto(image, forModel: User(), forCover: true) {
                e in
                if let e = e {
                    obs.onNext(e)
                } else {
                    let e = MySocialAppException()
                    e.setStringAttribute(withName: "message", "An error occured while uploading profile cover photo")
                    obs.onError(e)
                }
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
}
