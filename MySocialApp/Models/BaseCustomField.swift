import Foundation
import RxSwift

public class BaseCustomField : Base {
    private var fields: [CustomField]? {
        get { return (super.getAttributeInstance("custom_fields") as? JSONableArray<CustomField>)?.array }
        set(fields) { super.setArrayAttribute(withName: "custom_fields", fields) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        if name == "custom_fields" {
            return JSONableArray<CustomField>().initAttributes
        }
        return super.getAttributeCreationMethod(name: name)
    }
    
    internal func customValueCount() -> Int {
        if  let v = fields?.filter({ $0.data.getValue() != nil }).count {
            return v
        }
        return 0
    }
    
    public func blockingGetCustomFields() throws -> [CustomField] {
        if let cf = self.fields {
            return cf
        }
        return try getCustomFields().toBlocking().toArray()
    }
    
    public func setCustomFields(_ customFields: [CustomField]) {
        self.fields = customFields
    }
    
    public func getCustomFields() -> Observable<CustomField> {
        if let cf = self.fields {
            return Observable.create {
                obs in
                cf.forEach { obs.onNext($0) }
                obs.onCompleted()
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
        if let s = self.session {
            return Observable.create {
                obs in
                let _ = s.clientService.customField.list(for: self).subscribe {
                    e in
                    if let e = e.element?.array {
                        self.fields = e
                        e.forEach { obs.onNext($0) }
                    } else if let error = e.error {
                        obs.onError(error)
                    }
                    obs.onCompleted()
                }
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
        return Observable.create {
            obs in
            obs.onCompleted()
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
}

