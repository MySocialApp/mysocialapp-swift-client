import Foundation
import RxSwift

class RestConversationMessage: RestBase<ConversationMessage, ConversationMessage> {
    func list(_ page: Int, forConversation: Int64?) -> Observable<JSONableArray<ConversationMessage>> {
        if let id = forConversation {
            return super.list("/conversation/\(id)/message/consume", params: ["page": page as AnyObject, "size": 20 as AnyObject])
        }
        return super.listEmpty()
    }
    
    func listUnread(forConversation: Int64? = nil, consume: Bool = false) -> Observable<JSONableArray<ConversationMessage>> {
        var suffix = ""
        if consume {
            suffix = "/consume"
        }
        if let id = forConversation {
            return super.list("/conversation/\(id)/message/unread\(suffix)")
        } else {
            return super.list("/conversation/unread")
        }
    }
    
    func post(_ message: ConversationMessage, forConversation: Int64?) -> Observable<ConversationMessage> {
        if let id = forConversation {
            return super.post("/conversation/\(id)/message", input: message)
        }
        return super.getEmpty()
    }
    
    func post(_ message: ConversationMessage, forConversation: Int64?, withImage: UIImage, onComplete: @escaping (Base?)->Void) {
        if let id = forConversation {
            var data: [DataToUpload] = []
            if let d = ImageUtils.toData(withImage) {
                data.append(DataToUpload(data: d, name: "file", fileName: "image", mimeType: "image/jpeg"))
            }
            if let d = message.message?.data(using: .utf8) {
                data.append(DataToUpload(data: d, name: "message", fileName: nil, mimeType: "multipart/form-data"))
            }
            if let te = message.tagEntities, let json = te.getJSON(), let d = json.data(using: .utf8) {
                data.append(DataToUpload(data: d, name: "tag_entities", fileName: nil, mimeType: "multipart/form-data"))
            }
            if data.count > 0 {
                super.uploadRequest("/conversation/\(id)/message/photo", data: data, completionHandler: onComplete)
            } else {
                onComplete(nil)
            }
        } else {
            onComplete(nil)
        }
    }
}
