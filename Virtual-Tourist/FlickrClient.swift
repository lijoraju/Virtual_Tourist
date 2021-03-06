//
//  FlickrClient.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 22/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import Foundation
import CoreData

// MARK: Search and download photos from flickr api
func sentRequestToFlickrAPI(requestForPin pin: Pin, managedObjectContext moc: NSManagedObjectContext, completionHandler: @escaping(_ sucess: Bool, _ error: String?, _ errorMessage: String?)-> Void) {
    FlickrAPI.sharedInstance.searchPhotos(searchPin: pin, context: moc) { (sucess, errorString) in
        if sucess {
            completionHandler(true, nil, nil)
        }
        else {
            completionHandler(false, "Failed Downloading Photos", errorString)
        }
    }
}
