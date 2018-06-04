import Foundation

public class FeedPost {
    internal var textWallMessage: TextWallMessage? = nil
    internal var photo: UIImage? = nil
    
    public class Builder {
        private var mMessage: String? = nil
        private var mImage: UIImage? = nil
        private var mVisibility: AccessControl = .Friend
        
        public init() {}
        
        public func setMessage(_ message: String?) -> Builder {
            self.mMessage = message
            return self
        }
        
        public func setImage(_ image: UIImage?) -> Builder {
            self.mImage = image
            return self
        }
        
        public func setVisibility(_ visibility: AccessControl) -> Builder {
            self.mVisibility = visibility
            return self
        }
        
        public func build() throws -> FeedPost {
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
