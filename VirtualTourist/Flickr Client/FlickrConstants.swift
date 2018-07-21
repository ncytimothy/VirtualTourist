//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/13/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit

extension FlickrClient {
    
    // MARK: Constants
    struct Constants {
        // MARK: - Flickr
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
            
            static let SearchBoxHalfWidth = 0.005
            static let SearchBoxHalfHeight = 0.005
            static let SearchLatRange = (-90.0, 90.0)
            static let SearchLonRange = (-180.0, 180.0)
        }
        
        // MARK: - Flickr Parameter Keys
        struct FlickrParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let Text = "text"
            static let BoundingBox = "bbox"
            static let Page = "page"
        }
        
        // MARK: - Flickr Parameter Values
        struct FlickrParamterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "de2ec6f62c795c13cae2d372c5b99d8a"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1"
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"
        }
        
        // MARK: - Flickr Response Keys
        struct FlickrResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        // MARK: - Flickr Response Values
        struct FlickrResponseValues {
            static let OKStatus = "ok"
        }
    }
}
