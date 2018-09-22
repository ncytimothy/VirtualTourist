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
        
        var randomPage: String? = "1"
        
        // 2. MAKE THE REQUEST
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
           
            self.savePhotoToCoreData(result: result, dataController: dataController, pin: pin, { (success) in
                if success {
                    completionHandlerForDownloadPhoto(true, "")
                }
            })
        })
    }
    
    
    fileprivate func savePhotoToCoreData(result: AnyObject, dataController: DataController, pin: Pin, _ completionHandlerForSavePhotoToCoreData: @escaping(_ success: Bool) -> Void) {
        // 8. Convert JSON to usable Foundation objects
        let image = self.convertJSONToImage(result: result)
        
        
        // 9. Create and Configure Photo Core Data Object
        if let image = image {
            let photo = Photo(context: dataController.viewContext)
            photo.imageData = UIImagePNGRepresentation(image)
            photo.creationDate = Date()
            photo.uuid = UUID().uuidString
            photo.pin = pin
            
            // 10. Save the Photo Core Data Object
            do {
                try dataController.viewContext.save()
               completionHandlerForSavePhotoToCoreData(true)
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
        
        print("\(minLong), \(minLat), \(maxLong), \(maxLat)")
        
        return "\(minLong), \(minLat), \(maxLong), \(maxLat)"
    }
    
    func convertJSONToImages(result: AnyObject) -> [UIImage?] {
        
        var image: UIImage? = nil
        var images: [UIImage?] = []
     
        
        // 1. CONVERT THE JSON RESULT TO PHOTO DICTIONARIES AND PHOTO ARRAYS
        guard let photosDictionary = result[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
            print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(result)")
           return images
        }
        
                print("photoArray.count: \(photoArray.count)")
      
        
        print("images.count: \(images.count)")
        print("images: \(images)")
        
        //TODO: Get the random page as well
//        let pages = photosDictionary[Constants.FlickrResponseKeys.Photos] as? Int // in the guard line above 
//        let randomPage = Int(arc4random_uniform(UInt32(pages)))
        
        while images.count < 21 {
            let photoIndex: Int = Int(arc4random_uniform(UInt32(photoArray.count)))
            print("photoIndex: \(photoIndex)")
            let photoDictionary = photoArray[photoIndex] as [String:AnyObject]
            
            guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                return images
            }
            
            let imageURL = URL(string: imageURLString)
//            print("imageURLString: \(imageURLString)")
            if let imageData = try? Data(contentsOf: imageURL!) {
                image = UIImage(data: imageData)
                print("image: \(String(describing: image))")
                print("appending...")
                
                images.append(image)
                print("images: \(images)")
            }
           
        }
        return images
    }

    
    func convertJSONToImage(result: AnyObject) -> UIImage? {
        
        var image: UIImage? = nil
        
        // 1. CONVERT THE JSON RESULT TO PHOTO DICTIONARIES AND PHOTO ARRAYS
        guard let photosDictionary = result[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
            print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(result)")
            return image
        }
        
        // Debug Messages
        print("photoArray.count: \(photoArray.count)")
        
        let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as! Int
        print("totalPages: \(totalPages)")
        
        let randomPage = Int(arc4random_uniform(UInt32(totalPages)))
        
        
        let photoIndex: Int = Int(arc4random_uniform(UInt32(photoArray.count)))
        
            if !photoArray.isEmpty {
                let photoDictionary = photoArray[photoIndex] as [String:AnyObject]
                
                guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return image
                }
                
                let imageURL = URL(string: imageURLString)
                print("imageURLString: \(imageURLString)")
                if let imageData = try? Data(contentsOf: imageURL!) {
                    image = UIImage(data: imageData)
                }
            }
          return image
        }
    
    func getRandomPage(result: AnyObject) -> String? {

        var randomPage: Int? = nil
        var randomPageString: String? = nil

        // 1. Convert the JSON Result into Photo Dictionary
        guard let photosDictionary = result[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
            print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(result)")
            return randomPageString
        }
        
        guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
            print("Cannot find keys '\(Constants.FlickrResponseKeys.Pages)' in \(result)")
            return randomPageString
        }
        
        print("totalPages: \(totalPages)")
        
        randomPage = Int(arc4random_uniform(UInt32(totalPages))) + 1
        randomPageString = String(randomPage!)
        return randomPageString
        
    }
}



