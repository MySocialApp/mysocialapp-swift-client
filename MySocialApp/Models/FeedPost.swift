import Foundation

class FeedPost {
    internal var textWallMessage: TextWallMessage? = nil
    internal var photo: UIImage? = nil
    
    class Builder {
        private var mMessage: String? = nil
        private var mImage: UIImage? = nil
        private var mVisibility: AccessControl = .Friend
        
        func setMessage(_ message: String?) -> Builder {
            self.mMessage = message
            return self
        }
        
        func setImage(_ image: UIImage?) -> Builder {
            self.mImage = image
            return self
        }
        
        func setVisibility(_ visibility: AccessControl) -> Builder {
            self.mVisibility = visibility
            return self
        }
        
        func build() throws -> FeedPost {
            guard mMessage != nil || mImage != nil else {
                let e = RestError()
                e.setStringAttribute(withName: "message", "Message or image is mandatory")
                throw e
            }
            let post = FeedPost()
            post.textWallMessage = TextWallMessage()
            post.textWallMessage?.accessControl = mVisibility
            post.textWallMessage?.message = mMessage
            post.photo = mImage
            return post
        }
    }
    
}
