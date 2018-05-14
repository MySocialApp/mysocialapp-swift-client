import Foundation
import Alamofire
import RxSwift

class RestCommentable: RestBase<Comment, Comment> {
    
    private func getBaseUrl(_ commentable: Base) -> String? {
        if let id = commentable.id {
            if commentable is Photo {
                return "/photo/\(id)"
            }
            if commentable is Status {
                return "/status/\(id)"
            }
            return "/feed/\(id)"
        }
        return nil
    }
    
    func get(_ commentable: Base) -> Observable<JSONableArray<Comment>> {
        if let base = self.getBaseUrl(commentable) {
            return super.list("\(base)/comment")
        } else {
            return listEmpty()
        }
    }
    
    func post(_ commentable: Base, comment: Comment? = nil, image: Data?, withMimeType mimeType: String = "image/jpeg", onComplete: @escaping (Comment?)->Void) {
        if let base = self.getBaseUrl(commentable) {
            var url = "\(base)/comment"
            if let i = image {
                var data: [DataToUpload] = []
                data.append(DataToUpload(data: i, name: "file", fileName: "image", mimeType: mimeType))
                url += "/photo"
                if let d = comment?.message?.data(using: .utf8) {
                    data.append(DataToUpload(data: d, name: "name", fileName: nil, mimeType: "multipart/form-data"))
                }
                if let d = comment?.tagEntities?.getJSON()?.data(using: .utf8) {
                    data.append(DataToUpload(data: d, name: "tag_entities", fileName: nil, mimeType: "multipart/form-data"))
                }
                super.uploadRequest(url, data: data, completionHandler: onComplete)
            } else if let c = comment {
                if let id = comment?.id {
                    url += "/\(id)"
                    super.update(url, input: c).subscribe {
                        c in
                        onComplete(c.element)
                    }
                } else {
                    super.post(url, input: c).subscribe {
                        c in
                        onComplete(c.element)
                    }
                }
            } else {
                onComplete(nil)
            }
        } else {
            onComplete(nil)
        }
    }
    
    func delete(_ commentable: Base, comment: Comment) -> Observable<Bool> {
        if let base = self.getBaseUrl(commentable) {
            return super.delete("\(base)/comment")
        } else {
            return self.boolEmpty()
        }
    }
}
