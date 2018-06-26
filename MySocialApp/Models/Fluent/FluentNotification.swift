import Foundation
import RxSwift
import UserNotifications

public class FluentNotification {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }

    public lazy var unread: Unread = {
        Unread(self.session)
    }()
    public lazy var read: Read = {
        Read(self.session)
    }()

    init(_ session: Session) {
        self.session = session
    }
    
    public func blockingRegisterToken(_ token: Data) throws -> Bool? {
        return try self.registerToken(token).toBlocking().first()
    }
    
    public func registerToken(_ token: Data) -> Observable<Bool> {
        return Observable.create {
            obs in
            if let id = UIDevice.current.identifierForVendor?.uuidString.replacingOccurrences(of: "-", with: "") {
                self.session.clientService.device.post(Device(pushKey: token.map { String(format: "%02x", $0) }.joined(), deviceId: id)).subscribe {
                    e in
                    if let e = e.element {
                        obs.onNext(true)
                    } else {
                        obs.onNext(false)
                    }
                }
            } else {
                obs.onNext(false)
            }
            obs.onCompleted()
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingUnregisterToken() throws -> Bool? {
        return try self.unregisterToken().toBlocking().first()
    }
    
    public func unregisterToken() -> Observable<Bool> {
        return Observable.create {
            obs in
            if let id = UIDevice.current.identifierForVendor?.uuidString.replacingOccurrences(of: "-", with: "") {
                self.session.clientService.device.delete(id).subscribe {
                    e in
                    if let e = e.element {
                        obs.onNext(true)
                    } else {
                        obs.onNext(false)
                    }
                }
            } else {
                obs.onNext(false)
            }
            obs.onCompleted()
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(didReceive response: UNNotificationResponse) throws -> Notification? {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier,
            let u = response.notification.request.content.userInfo["URL"] as? String, let url = NSURL(string: u) {
            // TODO: handle the URL to get a notification in return
        }
        return nil
    }
    
    public func application(didReceiveRemoteNotification userInfo: [AnyHashable: Any]) throws -> Notification? {
        if var json = userInfo["json"] as? String?, json != nil, let n = Notification().initAttributes(nil, &json, nil, nil, nil) as? Notification {
            return n
        } else if let n = Notification().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, userInfo) as? Notification {
            return n
        }
        return nil
    }
    
    public func application(continue userActivity: NSUserActivity) throws -> Notification? {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL as? NSURL {
                // TODO: handle the URL to get a notification in return
            }
        }
        return nil
    }
    
    func application(open url: URL) throws -> Notification? {
        if url.scheme == session.configuration.appId, let u = NSURL(string: url.absoluteString) {
            // TODO: handle the URL to get a notification in return
        }
        return nil
    }
    
    func application(didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) throws -> Notification? {
        if let o = launchOptions?[.remoteNotification], let d = o as? NSDictionary {
            return Notification().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, d.dictionaryWithValues(forKeys: d.allKeys as! [String])) as? Notification
        }
        return nil
    }

    public class Unread {
        var session: Session
        
        init(_ session: Session) {
            self.session = session
        }
        
        private func scheduler() -> ImmediateSchedulerType {
            return self.session.clientConfiguration.scheduler
        }
        
        private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<PreviewNotification>) {
            if to > 0 {
                let _ = session.clientService.notification.listUnread(page, size: min(FluentNotification.PAGE_SIZE,to - (page * FluentNotification.PAGE_SIZE))).subscribe {
                    e in
                    if let e = e.element?.array {
                        e.forEach { obs.onNext($0) }
                        if e.count < FluentNotification.PAGE_SIZE {
                            obs.onCompleted()
                        } else {
                            self.stream(page + 1, to - FluentNotification.PAGE_SIZE, obs)
                        }
                    } else if let e = e.error {
                        obs.onError(e)
                        obs.onCompleted()
                    } else {
                        obs.onCompleted()
                    }
                }
            } else {
                obs.onCompleted()
            }
        }

        public func blockingStream(limit: Int = Int.max) throws -> [PreviewNotification] {
            return try stream(limit: limit).toBlocking().toArray()
        }
        
        public func stream(limit: Int = Int.max) -> Observable<PreviewNotification> {
            return list(page: 0, size: limit)
        }
        
        public func blockingList(page: Int = 0, size: Int = 10) throws -> [PreviewNotification] {
            return try list(page: page, size: size).toBlocking().toArray()
        }
        
        public func list(page: Int = 0, size: Int = 10) -> Observable<PreviewNotification> {
            return Observable.create {
                obs in
                self.stream(page, size, obs)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
    
    public class Read {
        var session: Session
        
        init(_ session: Session) {
            self.session = session
        }
        
        private func scheduler() -> ImmediateSchedulerType {
            return self.session.clientConfiguration.scheduler
        }
        
        private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<PreviewNotification>) {
            if to > 0 {
                let _ = session.clientService.notification.listRead(page, size: min(FluentNotification.PAGE_SIZE,to - (page * FluentNotification.PAGE_SIZE))).subscribe {
                    e in
                    if let e = e.element?.array {
                        e.forEach { obs.onNext($0) }
                        if e.count < FluentNotification.PAGE_SIZE {
                            obs.onCompleted()
                        } else {
                            self.stream(page + 1, to - FluentNotification.PAGE_SIZE, obs)
                        }
                    } else if let e = e.error {
                        obs.onError(e)
                        obs.onCompleted()
                    } else {
                        obs.onCompleted()
                    }
                }
            } else {
                obs.onCompleted()
            }
        }
        
        public func blockingStream(limit: Int = Int.max) throws -> [PreviewNotification] {
            return try stream(limit: limit).toBlocking().toArray()
        }
        
        public func stream(limit: Int = Int.max) -> Observable<PreviewNotification> {
            return list(page: 0, size: limit)
        }
        
        public func blockingList(page: Int = 0, size: Int = 10) throws -> [PreviewNotification] {
            return try list(page: page, size: size).toBlocking().toArray()
        }
        
        public func list(page: Int = 0, size: Int = 10) -> Observable<PreviewNotification> {
            return Observable.create {
                obs in
                self.stream(page, size, obs)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
}
