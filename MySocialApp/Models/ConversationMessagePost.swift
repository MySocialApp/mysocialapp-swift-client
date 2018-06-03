import Foundation

class ConversationMessagePost {
    internal var conversationMessage = ConversationMessage()
    internal var photo: UIImage? = nil
    
    class Builder {
        private var mMessage: String? = nil
        private var mImage: UIImage? = nil
        
        func setMessage(_ message: String?) -> Builder {
            self.mMessage = message
            return self
        }
        
        func setImage(image: UIImage?) -> Builder {
            self.mImage = image
            return self
        }
        
        func build() throws -> ConversationMessagePost {
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
