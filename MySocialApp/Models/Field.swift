import Foundation

class Field: Base {
    var fieldType: FieldType? {
        get { if let z = (super.getAttributeInstance("field_type") as! JSONableString?)?.string { return FieldType(rawValue: z) } else { return nil } }
        set(fieldType) { super.setStringAttribute(withName: "field_type", fieldType?.rawValue) }
    }
    var position: Int? {
        get { return (super.getAttributeInstance("position") as! JSONableInt?)?.int }
        set(position) { super.setIntAttribute(withName: "position", position) }
    }
    var important: Bool? {
        get { return (super.getAttributeInstance("important") as! JSONableBool?)?.bool }
        set(important) { super.setBoolAttribute(withName: "important", important) }
    }
    var defaultValue: Int? {
        get { return (super.getAttributeInstance("default_value") as! JSONableInt?)?.int }
        set(defaultValue) { super.setIntAttribute(withName: "default_value", defaultValue) }
    }
    var labels: [InterfaceLanguage:String]? {
        get {
            return (super.getAttributeInstance("labels") as? Localizable<JSONableString>)?.map.reduce([InterfaceLanguage:String]()) {
                m, e in
                var m = m
                if let v = e.value.string {
                    m[e.key] = v
                }
                return m
            }
        }
    }
    var descriptions: [InterfaceLanguage:String]? {
        get {
            return (super.getAttributeInstance("descriptions") as? Localizable<JSONableString>)?.map.reduce([InterfaceLanguage:String]()) {
                m, e in
                var m = m
                if let v = e.value.string {
                    m[e.key] = v
                }
                return m
            }
        }
    }
    var placeholders: [InterfaceLanguage:String]? {
        get {
            return (super.getAttributeInstance("placeholders") as? Localizable<JSONableString>)?.map.reduce([InterfaceLanguage:String]()) {
                m, e in
                var m = m
                if let v = e.value.string {
                    m[e.key] = v
                }
                return m
            }
        }
    }
    var values: [InterfaceLanguage:[String]]? {
        get {
            return (super.getAttributeInstance("values") as? Localizable<JSONableArray<JSONableString>>)?.map.reduce([InterfaceLanguage:[String]]()) {
                m, e in
                var m = m
                m[e.key] = e.value.array.flatMap { $0.string }
                return m
            }
        }
    }
    
    public func getValueIndex(_ forValue: String) -> Int? {
        if let v = self.values {
            for l in InterfaceLanguage.all {
                if let vv = v[l], let i = vv.index(of: forValue) {
                    return i
                }
            }
        }
        return nil
    }
    
    public func getLocalizedValue(_ forValue: String) -> String {
        if let v = self.values {
            if let i = self.getValueIndex(forValue), let vv = v[InterfaceLanguage.systemLanguage] {
                return vv[i]
            }
        }
        return forValue
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "field_type":
            return JSONableString().initAttributes
        case "position":
            return JSONableInt().initAttributes
        case "important":
            return JSONableBool().initAttributes
        case "labels", "descriptions", "placeholders":
            return Localizable<JSONableString>().initAttributes
        case "values":
            return Localizable<JSONableArray<JSONableString>>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
