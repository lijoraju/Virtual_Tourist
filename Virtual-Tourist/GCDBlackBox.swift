//
//  GCDBlackBox.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 13/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import Foundation
import CoreData

func performUIUpdateOnMain(updates: @escaping ()-> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

func performDataUpdatesOnBackground(updates: @escaping ()-> Void) {
    DispatchQueue.global(qos: .background).async {
        updates()
    }
}

// MARK: Save changes in the managed object context
func save(context moc : NSManagedObjectContext) {
    do {
        try moc.save()
    }
    catch let error as NSError{
        print("Error while saving \(error) \(error.userInfo)")
    }
}
