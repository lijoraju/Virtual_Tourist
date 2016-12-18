//
//  Photo+CoreDataProperties.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 18/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var index: Int16
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
