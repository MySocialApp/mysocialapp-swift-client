//
//  RestTextWallMessage.swift
//  nousmotards-ios
//
//  Created by Aurelien Bocquet on 24/12/2016.
//  Copyright © 2016 Nousmotards. All rights reserved.
//

import Foundation
import RxSwift

class RestTextWallMessage: RestBase<TextWallMessage, Base> {
    
    private func getBaseUrl(_ baseModel: Base, profile: Bool? = nil) -> String? {
        if let id = baseModel.getIdStr() {
            if baseModel is Event {
                return "/event/\(id)"
            }
            if baseModel is Group {
                if let _ = profile {
                    return "/group/\(id)/profile"
                }
                return "/group/\(id)"
            }
            if baseModel is Ride {
                return "/ride/\(id)"
            }
            if baseModel is User {
                if let _ = profile {
                    return "/account/profile"
                }
                return "/user/\(id)"
            }
            if baseModel is PhotoAlbum {
                return "/photo/album/\(id)"
            }
            if baseModel is PointOfInterest {
                return "/poi/\(id)"
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
    
    func post(forTarget target: Base, message: TextWallMessage?, album: String = "mes photos", profile: Bool? = nil, image: UIImage, onComplete: @escaping (Base?)->Void) {
        if let base = self.getBaseUrl(target, profile: profile) {
            var data: [DataToUpload] = []
            var url = "\(base)/photo"
            if let _ = target as? User, let p = profile, p {
                url = "/photo"
            }
            if let p = profile, !p {
                url = "\(base)/cover"
            }
            if let d = ImageUtils.toData(image) {
                data.append(DataToUpload(data: d, name: "file", fileName: "image", mimeType: "image/jpeg"))
            }
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
