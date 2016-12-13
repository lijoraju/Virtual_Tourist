//
//  Pin+CoreDataClass.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 13/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class Pin: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}
