//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/13/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import Foundation
import CoreData

class FlickrClient: NSObject {

    // MARK: - Properties
    
    // URL Shared Session
    var session = URLSession.shared
        
    // MARK: - GET
    func taskForGETMethod(_ parameters: [String:AnyObject], completionHandlerForGET: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // 1. BUILD THE URL, CONFIGURE THE REQUEST
        let request = URLRequest(url: flickrURL(parameters))
        print("flickrURL(parameters): \(flickrURL(parameters))")
        
        
        // 2. MAKE THE REQUEST
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // A. GUARD: WAS THERE AN ERROR?
            guard (error == nil) else {
                sendError("There was error with your request: \(String(describing: error))")
                return
            }
            
            // B. GUARD: DID WE GET A SUCCESSFUL 2XX RESPONSE?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // C. WAS THERE ANY DATA RETURNED?
            guard let data = data else {
                sendError("No data was returned by your request")
                return
            }
            
            // 3. PARSE THE DATA AND USE THE DATA (IN THE COMPLETION HANDLER)
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        })
        
        // 4. START THE REQUEST
        task.resume()
        return task
    }
    
    
    // MARK: - HELPERS
    
    // Create URL from method
    private func flickrURL(_ parameters: [String:AnyObject]) -> URL  {
        
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
    
    // Given raw data, try to serialize to JSON
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }

    // MARK: - Shared Instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

}
