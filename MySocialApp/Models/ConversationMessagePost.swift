import Foundation

public class ConversationMessagePost {
    internal var conversationMessage = ConversationMessage()
    internal var photo: UIImage? = nil
    
    public class Builder {
        private var mMessage: String? = nil
        private var mImage: UIImage? = nil
        
        public func setMessage(_ message: String?) -> Builder {
            self.mMessage = message
            return self
        }
        
        public func setImage(image: UIImage?) -> Builder {
            self.mImage = image
            return self
        }
        
        public func build() throws -> ConversationMessagePost {
            guard mMessage != nil || mImage != nil else {
                let e = RestError()
                e.setStringAttribute(withName: "message", "Message or image is mandatory")
                throw e
            }
            let post = ConversationMessagePost()
            post.conversationMessage.message = mMessage
            post.photo = mImage
            return post
        }
    }
    
}
