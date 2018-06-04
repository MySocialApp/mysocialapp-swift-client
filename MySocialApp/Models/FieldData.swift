import Foundation

public class FieldData: Base {
    public var fieldId: Int64? {
        get { return (super.getAttributeInstance("field_id") as! JSONableInt64?)?.int64 }
        set(fieldId) { super.setInt64Attribute(withName: "field_id", fieldId) }
    }
    public var fieldIdStr: String? {
        get { return (super.getAttributeInstance("field_id_str") as! JSONableString?)?.string }
        set(fieldIdStr) { super.setStringAttribute(withName: "field_id_str", fieldIdStr) }
    }
    public func getValue<T:JSONable>() -> T? {
        return super.getAttributeInstance("value", withCreationMethod: T().initAttributes) as? T
    }
    public func setValue(_ value: JSONable?) {
        super.setAttribute(withName: "value", value)
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "field_id":
            return JSONableInt64().initAttributes
        case "field_id_str":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}

