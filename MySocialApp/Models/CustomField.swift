import Foundation

public class CustomField: Base {
    
    internal var field: Field? {
        get { return self.getAttributeInstance("field") as? Field }
        set(field) { self.setAttribute(withName: "field", field) }
    }
    internal var data: FieldData {
        get {
            let d = self.getAttributeInstance("data")
            if d as? FieldData != nil {
                return d as! FieldData
            } else {
                let d = FieldData()
                d.fieldId = self.field?.id
                d.fieldIdStr = self.field?.idStr
                self.setAttribute(withName: "data", d)
                return d
            }
        }
        set(data) { self.setAttribute(withName: "data", data) }
    }
    
    private func getLocalizedValue(_ forValue: String?) -> String? {
        if let s = forValue, let f = self.field {
            return f.getLocalizedValue(s)
        }
        return forValue
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "field":
            return Field().initAttributes
        case "data":
            return FieldData().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public var fieldType: FieldType? {
        get { return self.field?.fieldType }
    }
    
    public var label: String? {
        get { return self.field?.labels?[InterfaceLanguage.systemLanguage] }
    }
    
    public override var description: String {
        get { return self.field?.descriptions?[InterfaceLanguage.systemLanguage] ?? "" }
    }
    
    public var placeholder: String? {
        get { return self.field?.placeholders?[InterfaceLanguage.systemLanguage] }
    }

    public var possibleValues: [String]? {
        get { return self.field?.values?[InterfaceLanguage.systemLanguage] }
    }
    
    public var boolValue: Bool? {
        get { return (self.data.getValue() as! JSONableBool?)?.bool }
        set(value) { if let v = value { self.data.setValue(JSONableBool(v)) } else { self.data.setValue(nil) } }
    }
    
    public var dateValue: Date? {
        get { return (self.data.getValue() as! JSONableDate?)?.date }
        set(value) { if let v = value { self.data.setValue(JSONableDate(v)) } else { self.data.setValue(nil) } }
    }
    
    public var stringsValue: [String]? {
        get { return (self.data.getValue() as! JSONableArray<JSONableString>?)?.array.flatMap { self.getLocalizedValue($0.string) } }
        set(value) { if let v = value { self.data.setValue(JSONableArray<JSONableString>(v.flatMap { JSONableString($0) })) } else { self.data.setValue(nil) } }
    }

    public var stringValue: String? {
        get { return self.getLocalizedValue((self.data.getValue() as! JSONableString?)?.string) }
        set(value) { if let v = value { self.data.setValue(JSONableString(v)) } else { self.data.setValue(nil) } }
    }

    public var doubleValue: Double? {
        get { return (self.data.getValue() as! JSONableDouble?)?.double }
        set(value) { if let v = value { self.data.setValue(JSONableDouble(v)) } else { self.data.setValue(nil) } }
    }

    public var locationValue: Location? {
        get { return self.data.getValue() as? Location }
        set(value) { self.data.setValue(value) }
    }

}
