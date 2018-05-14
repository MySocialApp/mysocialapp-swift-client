import Foundation
import RxSwift

class RestPhoto: RestBase<Photo, Photo> {

    func list(_ page: Int) -> Observable<JSONableArray<Photo>> {
        return super.list("/photo", params: ["page": page as AnyObject])
    }

    func get(_ id: Int64) -> Observable<Photo> {
        return super.get("/photo/\(id)")
    }

    func post(_ photo: Photo) -> Observable<Photo> {
        return super.post("/photo", input: photo)
    }

    func update(_ id: Int64, photo: Photo) -> Observable<Photo> {
        return super.update("/photo/\(id)", input: photo)
    }

    func delete(_ id: Int64) -> Observable<Bool> {
        return super.delete("/photo/\(id)")
    }
    
    func postPhoto(_ image: Data, withMimeType mimeType: String = "image/jpeg", forModel model: Base?, forCover cover: Bool = false, withTagEntities tagEntities: TagEntities? = nil, onComplete: @escaping (Photo?)->Void) {
        var data: [DataToUpload] = []
        var url: String?
        let appendPhoto = true
        if let _ = model as? User {
            url = "/account/profile"
        }
        if cover, let u = url {
            url = "\(u)/cover"
        }
        if let u = url, appendPhoto {
            url = "\(u)/photo"
        }
        data.append(DataToUpload(data: image, name: "file", fileName: "image", mimeType: mimeType))
        if let t = tagEntities?.getJSON()?.data(using: String.Encoding.utf8) {
            data.append(DataToUpload(data: t, name: "tag_entities", fileName: nil, mimeType: "multipart/form-data"))
        }
        if data.count > 0, let url = url {
            super.uploadRequest(url, data: data, completionHandler: onComplete)
        } else {
            onComplete(nil)
        }
    }


}
