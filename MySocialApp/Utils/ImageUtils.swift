import Foundation

internal struct ImageUtils {
    static func toData(_ image: UIImage) -> Data? {
        #if swift(>=4.2)
        let file = image.jpegData(compressionQuality: CGFloat(100))
        #else
        let file = UIImageJPEGRepresentation(image, CGFloat(100))
        #endif
        if let file = file {
            return file
        } else {
            return nil
        }
    }
}
