import Foundation
import RxSwift

class RestTextWallMessage: RestBase<TextWallMessage, Base> {
    
    private func getBaseUrl(_ baseModel: Base, profile: Bool? = nil) -> String? {
        if let id = baseModel.id {
            if baseModel is User {
                if let p = profile, p {
                    return "/account/profile"
                }
                return "/user/\(id)"
            }
        }
        return nil
    }

    func post(forTarget target: Base, message: TextWallMessage) -> Observable<Base> {
        if let u = self.getBaseUrl(target) {
            return super.post("\(u)/wall/message", input: message)
        }
        return super.getEmpty()
    }
    
    func post(forTarget target: Base, message: TextWallMessage?, album: String = "mes photos", profile: Bool? = nil, _ image: Data, withMimeType mimeType: String = "image/jpeg", onComplete: @escaping (Base?)->Void) {
        if let base = self.getBaseUrl(target, profile: profile) {
            var data: [DataToUpload] = []
            var url = "\(base)/photo"
            if let _ = target as? User, let p = profile, p {
                url = "/photo"
            }
            if let p = profile, !p {
                url = "\(base)/cover"
            }
            data.append(DataToUpload(data: image, name: "file", fileName: "image", mimeType: mimeType))
            if let d = album.data(using: .utf8) {
                data.append(DataToUpload(data: d, name: "album", fileName: nil, mimeType: "multipart/form-data"))
            }
            if let d = message?.message?.data(using: .utf8) {
                data.append(DataToUpload(data: d, name: "message", fileName: nil, mimeType: "multipart/form-data"))
            }
            if let p = message?.accessControl, let d = "\(p.rawValue)".data(using: .utf8) {
                data.append(DataToUpload(data: d, name: "access_control", fileName: nil, mimeType: "multipart/form-data"))
            }
            if let te = message?.tagEntities, let json = te.getJSON(), let d = json.data(using: .utf8) {
                data.append(DataToUpload(data: d, name: "tag_entities", fileName: nil, mimeType: "multipart/form-data"))
            }
            if data.count > 0 {
                super.uploadRequest(url, data: data, completionHandler: onComplete)
            } else {
                onComplete(nil)
            }
        } else {
            onComplete(nil)
        }
    }
    
    func update(_ message: TextWallMessage) -> Observable<Base> {
        if let id = message.idStr {
            return super.update("/user/0/wall/message/\(id)", input: message)
        } else {
            return super.getEmpty()
        }
    }
}
