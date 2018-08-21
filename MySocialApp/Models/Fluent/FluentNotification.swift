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
                let _ = self.session.clientService.device.post(Device(pushKey: token.map { String(format: "%02x", $0) }.joined(), deviceId: id)).subscribe {
                    e in
                    if let _ = e.element {
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
                let _ = self.session.clientService.device.delete(id).subscribe {
                    e in
                    if let _ = e.element {
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
    
    private func getNotificationFromUrl(_ url: NSURL) throws -> Notification? {
        guard var url = url.absoluteString else {
            return nil
        }
        if url.contains("\(session.configuration.appId)://url/") {
            url = url.replacingOccurrences(of: "\(session.configuration.appId)://url/", with: "")
        }
        if url.contains("\(session.configuration.appId)://relative/"), let webSiteUrl = (try session.clientService.backend.get("/config/\(session.configuration.appId)").toBlocking().first()?.getAttributeInstance("web_site_url", withCreationMethod: JSONableString().initAttributes) as? JSONableString)?.string {
            url = url.replacingOccurrences(of: "\(session.configuration.appId)://relative/", with: webSiteUrl)
        }
        var page = 0
        while let notifications = try self.session.clientService.notification.listUnread(page, size: FluentNotification.PAGE_SIZE).toBlocking().first()?.array, !notifications.isEmpty {
            page += 1
            if let notification = notifications.filter({ $0.lastNotification?.url == url }).first {
                return notification.lastNotification
            }
            if notifications.count < FluentNotification.PAGE_SIZE {
                break
            }
        }
        return nil
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(didReceive response: UNNotificationResponse) throws -> Notification? {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier,
            let u = response.notification.request.content.userInfo["URL"] as? String, let url = NSURL(string: u) {
            return try self.getNotificationFromUrl(url)
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
            if let url = userActivity.webpageURL {
                return try self.getNotificationFromUrl(url as NSURL)
            }
        }
        return nil
    }
    
    func application(open url: URL) throws -> Notification? {
        if url.scheme == session.configuration.appId, let u = NSURL(string: url.absoluteString) {
            return try self.getNotificationFromUrl(u)
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
        
        public func blockingTotal() throws -> Int? {
            return try self.total().toBlocking().first()
        }
        
        public func total() -> Observable<Int> {
            return Observable.create {
                obs in
                self.session.clientService.accountEvent.get().subscribe {
                    obs.onNext($0.element?.getUnreadNotifications() ?? 0)
                    obs.onCompleted()
                }
                return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
        }

        private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<PreviewNotification>, offset: Int = 0) {
            guard offset < FluentNotification.PAGE_SIZE else {
                self.stream(page+1, to, obs, offset: offset - FluentNotification.PAGE_SIZE)
                return
            }
            let size = min(FluentNotification.PAGE_SIZE,to - (page * FluentNotification.PAGE_SIZE))
            if size > 0 {
                let _ = session.clientService.notification.listUnread(page, size: size).subscribe {
                    e in
                    if let e = e.element?.array {
                        for i in offset..<e.count {
                            obs.onNext(e[i])
                        }
                        if e.count < FluentNotification.PAGE_SIZE {
                            obs.onCompleted()
                        } else {
                            self.stream(page + 1, to, obs)
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
                let to = (page+1) * size
                if size > FluentNotification.PAGE_SIZE {
                    var offset = page*size
                    let page = offset / FluentNotification.PAGE_SIZE
                    offset -= page * FluentNotification.PAGE_SIZE
                    self.stream(page, to, obs, offset: offset)
                } else {
                    self.stream(page, to, obs)
                }
                return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
        }
        
        public func blockingListAndConsume() throws -> [PreviewNotification] {
            return try self.listAndConsume().toBlocking().toArray()
        }
        
        public func listAndConsume() -> Observable<PreviewNotification> {
            return Observable.create {
                obs in
                let _ = self.session.clientService.notification.listUnreadConsume().subscribe {
                    e in
                    if let e = e.error {
                        obs.onError(e)
                    } else {
                        e.element?.iterate {
                            obs.onNext($0)
                        }
                    }
                    obs.onCompleted()
                }
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
        
        private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<PreviewNotification>, offset: Int = 0) {
            guard offset < FluentNotification.PAGE_SIZE else {
                self.stream(page+1, to, obs, offset: offset - FluentNotification.PAGE_SIZE)
                return
            }
            let size = min(FluentNotification.PAGE_SIZE,to - (page * FluentNotification.PAGE_SIZE))
            if size > 0 {
                let _ = session.clientService.notification.listRead(page, size: size).subscribe {
                    e in
                    if let e = e.element?.array {
                        for i in offset..<e.count {
                            obs.onNext(e[i])
                        }
                        if e.count < FluentNotification.PAGE_SIZE {
                            obs.onCompleted()
                        } else {
                            self.stream(page + 1, to, obs)
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
                let to = (page+1) * size
                if size > FluentNotification.PAGE_SIZE {
                    var offset = page*size
                    let page = offset / FluentNotification.PAGE_SIZE
                    offset -= page * FluentNotification.PAGE_SIZE
                    self.stream(page, to, obs, offset: offset)
                } else {
                    self.stream(page, to, obs)
                }
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
}
