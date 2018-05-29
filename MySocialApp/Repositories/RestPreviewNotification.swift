import Foundation
import RxSwift

class RestPreviewNotification: RestBase<PreviewNotification, PreviewNotification> {
    
    func listRead(_ page: Int) -> Observable<JSONableArray<PreviewNotification>> {
        return super.list("/notification/read", params: ["page": page as AnyObject])
    }
    
    func listUnread(_ page: Int, size: Int? = nil) -> Observable<JSONableArray<PreviewNotification>> {
        if let s = size {
            return super.list("/notification/unread", params: ["page": page as AnyObject, "size": s as AnyObject])
        } else {
            return super.list("/notification/unread", params: ["page": page as AnyObject])
        }
    }
    
    func listUnreadConsume() -> Observable<JSONableArray<PreviewNotification>> {
        return super.list("/notification/unread/consume")
    }
    
    func consume(_ id: Int64) -> Observable<PreviewNotification> {
        return super.get("/notification/\(id)/unread/consume")
    }
    
}

