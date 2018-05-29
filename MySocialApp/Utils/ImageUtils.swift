import Foundation

internal struct ImageUtils {
    static func toData(_ image: UIImage) -> Data? {
        if let file = UIImageJPEGRepresentation(image, CGFloat(100)) {
            return file
        } else {
            return nil
        }
    }
}
