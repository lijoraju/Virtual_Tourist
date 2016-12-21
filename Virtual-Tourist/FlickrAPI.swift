//
//  Flickr.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 14/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FlickrAPI {
    static let sharedInstance = FlickrAPI()
    
    // MARK: Search photos in flickr by latitude and longitude
    func searchPhotos(searchPin pin: Pin, context managedContext: NSManagedObjectContext, completionHandler: @escaping(_ sucess: Bool, _ errorString: String?)-> Void) {
        var methodParameters: [String: String] = [Constants.FlickrParameterKey.method: Constants.FlickrParameterValue.method,
                                                  Constants.FlickrParameterKey.apiKey: Constants.FlickrParameterValue.apiKey,
                                                  Constants.FlickrParameterKey.bbox: buildBBOX(latitude: pin.latitude, longitude: pin.longitude),
                                                  Constants.FlickrParameterKey.extras: Constants.FlickrParameterValue.mediumURL,
                                                  Constants.FlickrParameterKey.format: Constants.FlickrParameterValue.format,
                                                  Constants.FlickrParameterKey.noJSONCallBack: Constants.FlickrParameterValue.disableJSONCallBack]
        let selectedPage = randomPage(pin: pin, parameters: methodParameters)
        if selectedPage > 0 {
            methodParameters[Constants.FlickrParameterKey.page] = String(selectedPage)
        }
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(parameters: methodParameters as [String : AnyObject]))
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error occured.\(error)")
                return
            }
            guard let data = data else {
                print("No data returned by request")
                return
            }
            let parseResult: Any
            do {
                parseResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            }
            catch {
                print("Could not parse data as JSON \(data)")
                return
            }
            let result = parseResult as AnyObject
            guard let statusCode = result[Constants.FlickrResponseKey.status] as? String, statusCode == Constants.FlickrResponseValue.status else {
                print("Flickr API returned an error. Please see response code and messages in \(result)")
                return
            }
            guard let photoDictionaries = result[Constants.FlickrResponseKey.photos] as? [String: AnyObject], let pages = photoDictionaries[Constants.FlickrResponseKey.pages] as? Int, let photoArray = photoDictionaries[Constants.FlickrResponseKey.photo] as? [[String: AnyObject]] else {
                return
            }
            guard pages != 0  else {
                print("No phtotos available for the newly added pin.")
                return
            }
            guard let page = photoDictionaries[Constants.FlickrResponseKey.page] as? Int  else {
                print("Can't find key \(Constants.FlickrResponseKey.page) in \(result)")
                return
            }
            let totalPhotos = photoArray.count
            let photosLoading = min(29, (totalPhotos - 1))
            pin.currentPage = Int16(page)
            pin.numOfPhotos = Int16(photosLoading)
            pin.pages = Int16(pages)
            save(context: managedContext) { sucess in
                if sucess {
                    print("Saved no. of pages, no. of photos for given page and currentPage.")
                }
            }
            for index in 0...photosLoading {
                let photoDictionary = photoArray[index]
                guard let imageURL = photoDictionary[Constants.FlickrResponseKey.mediumURL] as? String else {
                    print("Can't find key \(Constants.FlickrResponseKey.mediumURL) in \(photoDictionary)")
                    return
                }
                let photo = Photo(context: managedContext)
                photo.index = index + 1
                photo.url = imageURL
                photo.image = nil
                photo.pin = pin
                save(context: managedContext) { sucess in
                    if sucess {
                        print("Saved index \(index) url_m = \(imageURL) ")
                    }
                }
            }
            completionHandler(true, nil)
        }
        task.resume()
    }
    
    // MARK: Choose a random page
    func randomPage(pin: Pin, parameters: [String:String])-> Int {
        let pages = Int(pin.pages)
        if pages > 1 {
            let pageLimit = min(pages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit)))
            return randomPage
        }
        return 0
    }
    
    // MARK: Forming bounding box with min longitude, min latitude, max longitude, max latitude
    private func buildBBOX(latitude: Double, longitude: Double)-> String {
        let minLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maxLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maxLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
    
    // MARK: Creating flickr URL for URLRequest from parameters
    func flickrURLFromParameters(parameters: [String: AnyObject])-> URL {
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }

    // MARK: Download the images from the stored urls
    func downloadImages(addedPin pin: Pin, context managedContext: NSManagedObjectContext, completionHandler: @escaping(_ sucess: Bool, _ error: String?)-> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin = %@", pin)
        fetchRequest.predicate = predicate
        var photos: [Photo] = []
        do {
            photos = try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Fetching error: \(error) \(error.userInfo)")
        }
        for photo in photos {
            if let imageURL = photo.url {
                let url = URL(string: imageURL)!
                let imageData = NSData(contentsOf: url)
                photo.image = imageData
                if photo.index == pin.numOfPhotos {
                    pin.downloadFlag = true
                }
                save(context: managedContext) { sucess in
                    if sucess {
                        print("Downloaded \(photo.index) photos")
                    }
                }
            }
        }
        completionHandler(true, nil)
    }
    
}
