import Foundation

public class CommentPost {
    internal var comment: Comment? = nil
    internal var photo: UIImage? = nil
    
    public class Builder {
        private var mMessage: String? = nil
        private var mImage: UIImage? = nil
        
        public init() {}
        
        public func setMessage(_ message: String?) -> Builder {
            self.mMessage = message
            return self
        }
        
        public func setImage(_ image: UIImage?) -> Builder {
            self.mImage = image
            return self
        }
        
        public func build() throws -> CommentPost {
            guard mMessage != nil || mImage != nil else {
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "Message or image is mandatory")
                throw e
            }
            let post = CommentPost()
            post.comment = Comment()
            post.comment?.message = mMessage
            post.photo = mImage
            return post
        }
    }
    
}
