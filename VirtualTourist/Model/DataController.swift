//
//  DataController.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/4/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Set up CoreData stack
// Use to create the stack and its functionality
// Note that the actual load of the persisted data happens in the AppDelegate.swift
class DataController {
    
    // Here we create a DataController class: since we need to pass the DataController across
    // multiple ViewControllers and we DON'T want mulitple copies
    
    // WANT THE CLASS TO DO THREE THINGS:
    // TODO:
    // 1) TO HOLD A PERSISTENT CONTAINTER INSTANCE
    // (CONTAINER INSTANCE: HELPS WITH CREATION OF THE STACK, AND PROVIDES CONVENIENCE METHODS)
    // 2) TO HELP LOAD THE PERSISTENCE STORE
    // 3) HELP ACCESS THE CONTEXT
    // (CONTEXT: AN INTELLIGENT SCRATCH PAD FOR TEMPORARY MANAGEDOBJECT CREATION
    // AND MANAGEMENT BEFORE STORING PERSISTENTLY)
    
   // 1) Persistent Container
    let persistentContainer: NSPersistentContainer
    
  // MARK: - Convenience property to access the context for PersistentController
    // 3) Access the viewContext of the persistent container
    var viewContext: NSManagedObjectContext {
        //TODO: Complete returning PersistentController's ViewContext
        /**
         The viewContext is associated with the main queue in GCD
        */
        return persistentContainer.viewContext
    }
    
     // Initializer for persistent container
    // TO INITIALIZE THE CONTAINER, YOU NEED A DATA MODEL NAME
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // 2) LOAD PERSISTENT STORE
    // MAKE A CONVENIENCE FUNCTION CALLED load()
   
    func load(completion: (() -> Void)? = nil) {
    /**
     Calls the Persistent Container's .loadPersistentStores(completionHandler:) function

     - parameter completion: function to be called after loading the persistent store
     - paramater completion: Is an optional and defaulted to nil
    
     */
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            // GUARD IF THERE IS ERROR, STOP EXECUTION OF APP IF ERROR EXISTS
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
}

extension DataController {
    
    // SAVING ON A TIMER (AUTOSAVING)
    // SET A FUNCTION TO BE CALLED AT REGULAR INTERVALS
    // EACH TIME THE INTERVAL PASSES, IF THE CONTEXT HAS ANY CHANGES
    // WE WILL TRY SAVING IT TO THE STORE
    // WRITE A METHOD THAT SAVES THE VIEW CONTEXT AND RECURSIVELY CALLS ITSELF AGAIN EVERY SO OFTEN
    
    func autoSaveViewContext(interval: TimeInterval = 30) {
        // TimeInterval PARAMETER VALUE DEFAULTED TO 30s
         
        
        // 1. GUARD POSITIVE TIME INTERVALS
        guard interval > 0 else {
            debugPrint("Cannot save negative intervals")
            return
        }
        
        // 2. SAVE TO STORE IF THE VIEW CONTEXT HAS CHANGES
        // NOTE THAT WE SHOULD NOT ALERT THE USER IF THE SAVE FAILS
        // WE WILL TRY IN THE NEXT INTERVAL
        // CHECK IF THE VIEW CONTEXT HAS CHANGES
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        // 3. RECURSIVE CALL OF THE FUNCTION ITSELF ON MAIN QUEUE
        // NOTICE THAT AFTER THE INTERVAL (30s) HAS PASSED FROM NOW
        // YOU WILL SEE THAT .autoSaveViewContext(interval: interval) is being called as a closure expression
        // THEREFORE THE FUNCTION CALL IS RECURSIVE
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
        
        // 4. KICK OFF THE INITIAL AUTOSAVE IN .load()
        
        
    }
    
}
