//
//  Constants.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 14/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import Foundation

class Constants {
    static var selectedPin: Pin!
    
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        static let SearchBBoxHalfWidth = 0.25
        static let SearchBBoxHalfHeight = 0.25
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    struct FlickrParameterKey {
        static let method = "method"
        static let latitude = "lat"
        static let longitude = "lon"
        static let apiKey = "api_key"
        static let extras = "extras"
        static let format = "format"
        static let noJSONCallBack = "nojsoncallback"
        static let bbox = "bbox"
    }
    
    struct FlickrParameterValue {
        static let method = "flickr.photos.search"
        static let apiKey = "028a47f3a6a0807019fdd3d10ea16eb0"
        static let format = "json"
        static let disableJSONCallBack = "1"
        static let mediumURL = "url_m"
    }
    
    struct FlickrResponseKey {
        static let status = "stat"
        static let photos = "photos"
        static let photo = "photo"
        static let mediumURL = "url_m"
        static let pages = "pages"
    }
    
    struct FlickrResponseValue {
        static let status = "ok"
    }
    
    struct FlickrDownloadedPhotos {
        static var total: Int!
    }
    
}
