//
//  LocationUtils.swift
//  MySocialApp
//
//  Created by Aurelien Bocquet on 13/05/2018.
//  Copyright © 2018 4Tech. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationUtils {
    static func toLocation(_ l: CLLocation) -> Location {
        let location = Location()
        location.latitude = l.coordinate.latitude
        location.longitude = l.coordinate.longitude
        location.accuracy = Float(l.horizontalAccuracy)
        return location
    }
    static func fromLocation(_ fromLocation: BaseLocation) -> CLLocation? {
        if let ln = fromLocation.longitude, let lt = fromLocation.latitude {
            return CLLocation(latitude: lt, longitude: ln)
        } else {
            return nil
        }
    }
}
