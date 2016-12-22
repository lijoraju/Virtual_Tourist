//
//  SaveContext.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 22/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import Foundation
import CoreData

// MARK: Save changes in the managed object context
func save(context moc : NSManagedObjectContext, completionHandler:@escaping(_ sucess: Bool)-> Void ) {
    do {
        try moc.save()
        completionHandler(true)
    }
    catch let error as NSError {
        print("Error while saving \(error) \(error.userInfo)")
        completionHandler(false)
    }
}
