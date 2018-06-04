import Foundation
import RxSwift

public class UserStat: Base {
    
    public var status: UserStatStatus? {
        get { return self.getAttributeInstance("status") as? UserStatStatus }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "status":
            return UserStatStatus().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }

    public var createdRides: Int? { get {
        if let d = (self.getAttributeInstance("rides")?.getAttributeInstance("created", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }
    
    public var doneRides: Int? { get {
        if let d = (self.getAttributeInstance("rides")?.getAttributeInstance("done", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }
    
    public var distanceRides: Int64? { get {
        if let d = (self.getAttributeInstance("rides")?.getAttributeInstance("distance", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int64(d)
        }
        return nil
    } }
    
    public var totalFriends: Int? { get {
        if let d = (self.getAttributeInstance("friend")?.getAttributeInstance("total", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }
    
    public var totalPhotos: Int? { get {
        if let d = (self.getAttributeInstance("photos")?.getAttributeInstance("total", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }
}
