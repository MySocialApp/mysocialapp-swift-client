import Foundation
import RxSwift

class UserStat: Base {
    
    var status: UserStatStatus? {
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

    var createdRides: Int? { get {
        if let d = (self.getAttributeInstance("rides")?.getAttributeInstance("created", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }
    
    var doneRides: Int? { get {
        if let d = (self.getAttributeInstance("rides")?.getAttributeInstance("done", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }
    
    var distanceRides: Int64? { get {
        if let d = (self.getAttributeInstance("rides")?.getAttributeInstance("distance", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int64(d)
        }
        return nil
    } }
    
    var totalFriends: Int? { get {
        if let d = (self.getAttributeInstance("friend")?.getAttributeInstance("total", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }
    
    var totalPhotos: Int? { get {
        if let d = (self.getAttributeInstance("photos")?.getAttributeInstance("total", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }
}
