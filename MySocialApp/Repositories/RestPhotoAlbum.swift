import Foundation
import RxSwift

class RestPhotoAlbum: RestBase<PhotoAlbum, PhotoAlbum> {
    
    func list(_ page: Int, forRider: User? = nil, forGroup: Group? = nil, forEvent: Event? = nil, forRide: Ride? = nil) -> Observable<JSONableArray<PhotoAlbum>> {
        if let r = forRider, let id = r.id {
            return super.list("/user/\(id)/photo/album", params: ["page": page as AnyObject])
        } else if let g = forGroup, let id = g.id {
            return super.list("/group/\(id)/photo/album", params: ["page": page as AnyObject])
        } else if let e = forEvent, let id = e.id {
            return super.list("/event/\(id)/photo/album", params: ["page": page as AnyObject])
        } else if let r = forRide, let id = r.id {
            return super.list("/ride/\(id)/photo/album", params: ["page": page as AnyObject])
        }
        return super.list("/photo", params: ["page": page as AnyObject])
    }
    
    func get(_ id: Int64) -> Observable<PhotoAlbum> {
        return super.get("/photo/album/\(id)")
    }
    
    func post(_ album: PhotoAlbum) -> Observable<PhotoAlbum> {
        return super.post("/photo/album", input: album)
    }
    
    func update(_ id: Int64, album: PhotoAlbum) -> Observable<PhotoAlbum> {
        return super.update("/photo/album/\(id)", input: album)
    }
    
    func delete(_ id: Int64) -> Observable<Bool> {
        return super.delete("/photo/album/\(id)")
    }
}
