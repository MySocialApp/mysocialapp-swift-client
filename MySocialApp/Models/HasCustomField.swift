import Foundation

class BaseCustomField : Base {
    var customFields: [CustomField]? {
        get { return (super.getAttributeInstance("custom_fields") as? JSONableArray<CustomField>)?.array }
        set(customFields) { super.setArrayAttribute(withName: "custom_fields", customFields) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        if name == "custom_fields" {
            return JSONableArray<CustomField>().initAttributes
        }
        return super.getAttributeCreationMethod(name: name)
    }
    
    func customValueCount() -> Int {
        if  let v = customFields?.filter({ $0.data != nil }).count {
            return v
        }
        return 0
    }
}

