import Foundation

internal struct ImageUtils {
    static func toData(_ image: UIImage) -> Data? {
        if let file = image.jpegData(compressionQuality: CGFloat(100)) {
            return file
        } else {
            return nil
        }
    }
}
