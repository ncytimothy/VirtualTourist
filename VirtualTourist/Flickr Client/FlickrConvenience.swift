//
//  FlickrConveniene.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/13/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit

extension FlickrClient {
    
    func getPicture(latitude: Double, longitude: Double, _ completionHandlerForPicture: @escaping(_ success: Bool,_ image: UIImage?, _ errorString: String?) -> Void) {
        
        // 1. SPECIFY THE PARAMETERS
        let parameters =
            [Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParamterValues.UseSafeSearch,
             Constants.FlickrParameterKeys.Extras : Constants.FlickrParamterValues.MediumURL,
             Constants.FlickrParameterKeys.APIKey : Constants.FlickrParamterValues.APIKey,
             Constants.FlickrParameterKeys.Method : Constants.FlickrParamterValues.SearchMethod,
             Constants.FlickrParameterKeys.Format : Constants.FlickrParamterValues.ResponseFormat,
             Constants.FlickrParameterKeys.NoJSONCallback : Constants.FlickrParamterValues.DisableJSONCallback,
             Constants.FlickrParameterKeys.BoundingBox : bboxString(latitude: latitude, longitude: longitude)
        ] as [String:AnyObject]
        
        // 2. MAKE THE REQUEST
        let _ = taskForGETMethod(parameters, completionHandlerForGET: {(result, error) in
            
            // 3. SEND THE DESIRED VALUE(S) TO COMPLETION HANDLER
            guard (error == nil) else {
                completionHandlerForPicture(false, nil, "Get Pictures Failed.")
                return
            }
            
            // 4. ARE RESULTS RETURNED?
            guard let result = result else {
                print("Cannot get result!")
                return
            }
            
            // 5. CONVERT THE JSON OBJECT RESULTS INTO USABLE FOUNATION OBJECTS
            let image = self.convertJSONToImage(result: result)
            completionHandlerForPicture(true, image, nil)
        })
    }
    
    func bboxString(latitude: Double, longitude: Double) -> String {
        
        let minLat = max(latitude - Constants.Flickr.SearchBoxHalfWidth, Constants.Flickr.SearchLatRange.0)
        let maxLat = min(latitude + Constants.Flickr.SearchBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        let minLong = max(longitude - Constants.Flickr.SearchBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let maxLong = min(longitude + Constants.Flickr.SearchBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        
        return "\(minLong), \(minLat), \(maxLong), \(maxLat)"
    }
    
    func convertJSONToImage(result: AnyObject) -> UIImage? {
        
        var image: UIImage? = nil
        
        // 1. CONVERT THE JSON RESULT TO PHOTO DICTIONARIES AND PHOTO ARRAYS
        guard let photosDictionary = result[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
            print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(result)")
           return image
        }
        
        let photoDictionary = photoArray[0] as [String:AnyObject]
        
        guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
            print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
            return image
        }
        
        let imageURL = URL(string: imageURLString)
        if let imageData = try? Data(contentsOf: imageURL!) {
            image = UIImage(data: imageData)
        }
        
        return image
    }
}

