//
//  FlickrConveniene.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/13/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit

extension FlickrClient {
    
    func downloadPhoto(latitude: Double, longitude: Double, _ completionHandlerForDownloadPhoto: @escaping(_ success: Bool,_ image: UIImage?, _ errorString: String?) -> Void) {
        
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
                completionHandlerForDownloadPhoto(false, nil, "Cannot download photos")
                return
            }
            
            // 4. ARE RESULTS RETURNED?
            guard let result = result else {
                print("Cannot get result!")
                return
            }
            
            // 5. CONVERT THE JSON OBJECT RESULTS INTO USABLE FOUNATION OBJECTS
            let image = self.convertJSONToImage(result: result)
            completionHandlerForDownloadPhoto(true, image, nil)
        })
    }
    
    func downloadPhotos(latitude: Double, longitude: Double, _ completionHandlerForDownloadPhotos: @escaping(_ success: Bool,_ images: [UIImage?], _ errorString: String?) -> Void) {
        
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
                completionHandlerForDownloadPhotos(false, [], "Cannot download photos")
                return
            }
            
            // 4. ARE RESULTS RETURNED?
            guard let result = result else {
                print("Cannot get result!")
                return
            }
            
            // 5. CONVERT THE JSON OBJECT RESULTS INTO USABLE FOUNATION OBJECTS
            let images = self.convertJSONToImages(result: result)
            
            // (Current) Handling images (data) towards the completion handler
            // I don't want that
            // TODO: SHOULD TRIGGER PERSISTENT DATA SAVE HERE
            
            completionHandlerForDownloadPhotos(true, images, "")
        })
    }
    
    func bboxString(latitude: Double, longitude: Double) -> String {
        
        let minLat = max(latitude - Constants.Flickr.SearchBoxHalfWidth, Constants.Flickr.SearchLatRange.0)
        let maxLat = min(latitude + Constants.Flickr.SearchBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        let minLong = max(longitude - Constants.Flickr.SearchBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let maxLong = min(longitude + Constants.Flickr.SearchBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        
        print("\(minLong), \(minLat), \(maxLong), \(maxLat)")
        
        return "\(minLong), \(minLat), \(maxLong), \(maxLat)"
    }
    
    func convertJSONToImages(result: AnyObject) -> [UIImage?] {
        
        var image: UIImage? = nil
        var images: [UIImage?] = []
        var photoCount: Int = 0
        
        // 1. CONVERT THE JSON RESULT TO PHOTO DICTIONARIES AND PHOTO ARRAYS
        guard let photosDictionary = result[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
            print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(result)")
           return images
        }
        
        while photoCount < 21 {
            let photoDictionary = photoArray[photoCount] as [String:AnyObject]
            
            guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                return images
            }
            
            let imageURL = URL(string: imageURLString)
            if let imageData = try? Data(contentsOf: imageURL!) {
                image = UIImage(data: imageData)
                images.append(image)
                photoCount += 1
            }
        }
    
        return images
    }
    
    func convertJSONToImage(result: AnyObject) -> UIImage? {
        
        var image: UIImage? = nil
        var photoCount: Int = 0
        
        // 1. CONVERT THE JSON RESULT TO PHOTO DICTIONARIES AND PHOTO ARRAYS
        guard let photosDictionary = result[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
            print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(result)")
            return image
        }
        
            let photoDictionary = photoArray[photoCount] as [String:AnyObject]
            
            guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                return image
            }
            
            let imageURL = URL(string: imageURLString)
            if let imageData = try? Data(contentsOf: imageURL!) {
                image = UIImage(data: imageData)
//                images.append(image)
//                photoCount += 1
            }
        
        return image
    }
}

