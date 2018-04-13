//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/12/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import Foundation
import CoreData
import MapKit

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
    
    class func keyPathsValuesAffectingCoordinate() -> Set<String> {
        return Set<String>([ #keyPath(latitude), #keyPath(longitude) ])
    }
}
