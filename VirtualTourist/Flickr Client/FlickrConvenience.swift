//
//  FlickrConveniene.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/13/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit
import CoreData

extension FlickrClient {
        
    func downloadPhoto(latitude: Double, longitude: Double, dataController: DataController, pin: Pin, _ completionHandlerForDownloadPhoto: @escaping(_ success: Bool, _ errorString: String?) -> Void) {

        var randomPage: Int = 1
        var randomPageString: String = "1"

        // 1. SPECIFY THE PARAMETERS
        var parameters =
            [Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParamterValues.UseSafeSearch,
             Constants.FlickrParameterKeys.Extras : Constants.FlickrParamterValues.MediumURL,
             Constants.FlickrParameterKeys.APIKey : Constants.FlickrParamterValues.APIKey,
             Constants.FlickrParameterKeys.Method : Constants.FlickrParamterValues.SearchMethod,
             Constants.FlickrParameterKeys.Format : Constants.FlickrParamterValues.ResponseFormat,
             Constants.FlickrParameterKeys.NoJSONCallback : Constants.FlickrParamterValues.DisableJSONCallback,
             Constants.FlickrParameterKeys.BoundingBox : bboxString(latitude: latitude, longitude: longitude)
                ] as [String:AnyObject]

        let _ = taskForGETMethod(parameters, completionHandlerForGET: {(result, error) in
            
            // 3. SEND THE DESIRED VALUE(S) TO COMPLETION HANDLER
            guard (error == nil) else {
                completionHandlerForDownloadPhoto(false, "Cannot download photos")
                return
            }
            
            // 4. ARE RESULTS RETURNED?
            guard let result = result else {
                print("Cannot get result!")
                return
            }
           
            // 5. Produce Random Page
            let totalPages = self.convertJSONToTotalPages(result: result)
            if let totalPages = totalPages {
                randomPage = Int(arc4random_uniform(UInt32(totalPages)))
                randomPageString = String(randomPage)
            }
           
        })
        
        // 6. Append Random Page to Parameters
        parameters[Constants.FlickrParameterKeys.Page] = randomPageString as AnyObject

        // 7. Make another request with the random page
        let _ = taskForGETMethod(parameters, completionHandlerForGET: {(result, error) in

            // 8. Check for errors
            guard (error == nil) else {
                completionHandlerForDownloadPhoto(false, "Cannot download photos")
                return
            }

            // 9. Are results returned?
            guard let result = result else {
                print("Cannot get result!")
                return
            }

            // 10. Save the photo with imageURL into Core Data
            self.savePhotoToCoreData(result: result, dataController: dataController, pin: pin, { (success) in
                if success {
                    completionHandlerForDownloadPhoto(true, "")
                }
            })
        })
    }
    
    fileprivate func savePhotoToCoreData(result: AnyObject, dataController: DataController, pin: Pin, _ completionHandlerForSaveToCoreData: @escaping(_ success: Bool) -> Void) {
        
        let imageURL = self.convertJSONToURL(result: result)
        
        if let imageURL = imageURL {
            let photo = Photo(context: dataController.viewContext)
            photo.imageURL = imageURL
            photo.imageData = nil
            photo.creationDate = Date()
            photo.uuid = UUID().uuidString
            photo.pin = pin
            
            do {
                try dataController.viewContext.save()
            } catch {
                let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
            }
            
        }
        
    }
    
    func bboxString(latitude: Double, longitude: Double) -> String {
        
        let minLat = max(latitude - Constants.Flickr.SearchBoxHalfWidth, Constants.Flickr.SearchLatRange.0)
        let maxLat = min(latitude + Constants.Flickr.SearchBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        let minLong = max(longitude - Constants.Flickr.SearchBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let maxLong = min(longitude + Constants.Flickr.SearchBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        
        return "\(minLong), \(minLat), \(maxLong), \(maxLat)"
    }
    
    fileprivate func convertJSONToURL(result: AnyObject) -> URL? {
        // 1. Create the imageURL to be returned
        var imageURL: URL? = nil
        
        // 2. Convert the JSON result to Photo Dictionaries and Photo Arrays
        guard let photosDictionary = result[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
            print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(result)")
            return imageURL
        }
        
        let photoIndex: Int = Int(arc4random_uniform(UInt32(photoArray.count)))
        
        if !photoArray.isEmpty {
            let photoDictionary = photoArray[photoIndex] as [String:AnyObject]
            
            guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                return imageURL
            }
            
            // For Debug purposes to get imageURL, use
//            print("FlickrConvenience: convertJSONToURL: imageURLString: \(imageURLString)")
            
            imageURL = URL(string: imageURLString)
        }
        return imageURL
    }
    
    fileprivate func convertJSONToTotalPages(result: AnyObject) -> Int? {
        // 1. Create the totalPages to be returned
        var totalPages: Int? = nil
        
        // 2. Convert the JSON result to Photo Dictionaries and Photo Arrays
        guard let photosDictionary = result[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let pages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
            
            return totalPages
        }
        
        totalPages = pages
        
        return totalPages
    }
}
