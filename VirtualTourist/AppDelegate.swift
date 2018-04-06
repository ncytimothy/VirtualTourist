//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 3/27/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // DataController property for persistent store
    let dataController = DataController(modelName: "VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Call dataController.load() to load persistent store
        // Note that the trailing closure parameter attached to the .load() gives
        // us the capability to present a loading UI while persisted data is
        // being retrieved
        
        // Configure the first view
        // Get NavigationController from the window's rootViewController
        // Navigation Controller's top view is the MapView (TravelLocations)
        // Set travelLoationsViewController' data controller property to the AppDelegate's dataController
        // This will inject the dataController depency into the TravelLoationsViewController
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLoocationsViewController = navigationController.topViewController as! TravelLocationsViewController
        travelLoocationsViewController.dataController = dataController
        
        dataController.load()
        
//        // USE IF NEEDED
//        dataController.load {
//            // Update the main UI after persistent store is loaded
//        }
//
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }
    
    //TODO: Set a function to be called at regular intervals
    
    func saveViewContext() {
        /** Helper Method
        * Calls save on the Data Controller's view context
        * To be used in applicationDidEnterBackground and applicationWillTerminate
        */
        do {
            try dataController.viewContext.save()
        } catch {
            fatalError("dataController.viewContext cannot be save!")
        }
    }


}

