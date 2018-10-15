import Foundation
import RxSwift

class RestPhoto: RestBase<Photo, Photo> {

    func list(_ page: Int, size: Int = 10, forPhotoAlbum: PhotoAlbum? = nil) -> Observable<JSONableArray<Photo>> {
        if let a = forPhotoAlbum, let id = a.id {
            return super.list("/photo/album/\(id)/photo", params: ["page": page as AnyObject, "size": size as AnyObject])
        }
        return super.list("/photo", params: ["page": page as AnyObject, "size": size as AnyObject])
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
    
    func postPhoto(_ image: UIImage, forModel model: Base?, forCover cover: Bool = false, withTagEntities tagEntities: TagEntities? = nil, onComplete: @escaping (Photo?)->Void) {
        var data: [DataToUpload] = []
        var url: String?
        let appendPhoto = true
        if let _ = model as? User {
            url = "/account/profile"
        } else if let c = model as? Group, let id = c.id {
            url = "/group/\(id)/profile"
        } else if let e = model as? Event, let id = e.id {
            url = "/event/\(id)/profile"
            //appendPhoto = false
        }
        if cover, let u = url {
            url = "\(u)/cover"
        }
        if let u = url, appendPhoto {
            url = "\(u)/photo"
        }
        if let d = ImageUtils.toData(image) {
            data.append(DataToUpload(data: d, name: "file", fileName: "image", mimeType: "image/jpeg"))
        }
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
