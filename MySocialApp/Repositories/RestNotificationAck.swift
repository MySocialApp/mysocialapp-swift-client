import Foundation
import RxSwift

class RestNotificationAck: RestBase<NotificationAck, NotificationAck> {
    
    func post(_ notificationAck: NotificationAck) -> Observable<NotificationAck> {
        return super.post("/notification/ack", input: notificationAck)
    }

}
