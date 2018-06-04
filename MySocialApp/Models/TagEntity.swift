import Foundation

public class TagEntity: Base {

    public var text: String?{
        get { return (super.getAttributeInstance("text") as! JSONableString?)?.string }
        set(text) { super.setStringAttribute(withName: "text", text) }
    }
    public var target: Base?{
        get { return super.getAttributeInstance("target") as? Base }
        set(target) { super.setAttribute(withName: "target", target) }
    }
    public var user: User?{
        get { return super.getAttributeInstance("user") as? User }
        set(user) { super.setAttribute(withName: "user", user) }
    }
    public var indices: [Int]?{
        get { if let i = (super.getAttributeInstance("indices") as! JSONableArray<JSONableInt>?)?.getDictArray() as? [Int] {
            return i
        } else if let si = self.startIndex, let ei = self.endIndex {
            return [si,ei]
        } else {
            return nil
            }
        }
        set(indices) {
            if let i = indices {
                var a: [JSONableInt] = [];
                for ind in i {
                    a.append(JSONableInt(ind))
                }
                super.setArrayAttribute(withName: "indices", a)
                if i.count > 0 {
                    self.startIndex = i[0]
                    if i.count > 1 {
                        self.endIndex = i[1]
                    }
                }
            } else {
                super.setArrayAttribute(withName: "indices", nil)
                self.startIndex = nil
                self.endIndex = nil
            }
        }
    }
    public var startIndex: Int? {
        get { return (super.getAttributeInstance("start_index") as! JSONableInt?)?.int }
        set(startIndex) { super.setIntAttribute(withName: "start_index", startIndex) }
    }
    public var endIndex: Int? {
        get { return (super.getAttributeInstance("end_index") as! JSONableInt?)?.int }
        set(endIndex) { super.setIntAttribute(withName: "end_index", endIndex) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "user":
            return User().initAttributes
        case "target":
            return Base().initAttributes
        case "text":
            return JSONableString().initAttributes
        case "indices":
            return JSONableArray<JSONableInt>().initAttributes
        case "start_index", "end_index":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
