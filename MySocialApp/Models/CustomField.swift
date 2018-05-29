import Foundation

class CustomField: Base {
    
    var field: Field? {
        get { return self.getAttributeInstance("field") as? Field }
        set(field) { self.setAttribute(withName: "field", field) }
    }
    var data: FieldData? {
        get { return self.getAttributeInstance("data") as? FieldData }
        set(data) { self.setAttribute(withName: "data", data) }
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
}
