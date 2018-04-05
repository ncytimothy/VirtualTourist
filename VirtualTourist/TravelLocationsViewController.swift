//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 3/27/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit
import MapKit
// IMPORT CORE DATA
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Properties
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var mapView: MKMapView!
    // THE 'PINS' OBJECTS BEING DISPLAYED
    var pins: [Pin] = []
    // Data Controller property from AppDelegate.swift
    var dataController: DataController!
    // MKAnnoations Array
    var annotations = [MKAnnotation]()
    
    let center = CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452)
    let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    var region = MKCoordinateRegion()
    
    // FETCH REQUEST
    // SELECTS INTERESTED DATA
    // LOADS THE DATA FROM PERSISTENT STORE INTO THE CONTEXT
    // MUST BE CONFIGURED WITH AN ENTITY TYPE
    // CAN OPTIONALLY INCLUDE FILTERING AND SORTING
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // 1. CREATE FETCH REQUEST
        // FETCH REQUESTS ARE GENERIC TYPES, SO YOU SPECIFY THE TYPE PARAMETER
        // SPECIFYING THE TYPE PARAMETER WILL MAKE THE FETCH REQUEST
        // WORK WITH A SPECIFIC MANAGED OBJECT SUBCLASS
        // CALL THE TYPE FUNCTON FETCH REQUEST ON THAT SUBCLASS
        // Pin.fetchRequest() returns a fetch request initialized with the entity
        
        let pinFetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        // 2. CONFIGURE FETCH REQUEST BY ADDING A SORT RULE
        // fetchRequest.sortDescriptors property takes an array of sort descriptors
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        pinFetchRequest.sortDescriptors = [sortDescriptor]
       
        
        // 3. USE THE FETCH REQUEST
        // ASK A CONTEXT TO EXECUTE THE REQUEST
        // ASK DATA CONTROLLER'S VIEW CONTEXT (PERSISTENT CONTROLLER'S VIEW CONTEXT)
        // .fetch() CAN THROW AN ERROR
        // SAVE THE RESULTS ONLY IF THE FETCH IS SUCCESSFUL
        // USE try? TO CONVERT THE ERROR INTO AN OPTIONAL
        if let result = try? dataController.viewContext.fetch(pinFetchRequest) {
            // IF FETCH REQUEST SUCCESSFUL, STORE THE RESULT IN THE ARRAY FOR PINS
            pins = result
            //TODO: RELOAD MAPVIEW
           reloadMapView()
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        addPin(coordinate: locationCoordinate)
        reloadMapView()
    }
    
    // MARK: - Add Pin
    func addPin(coordinate: CLLocationCoordinate2D) {
        // 1. ASSOCIATE PIN WITH THE DATA CONTROLLER'S VIEW CONTEXT
        let pin = Pin(context: dataController.viewContext)
        // 2. CONFIGURE THE PIN OBJECT
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        pin.creationDate = Date()
        // 3. SAVE THE PIN INTO THE PERSISTENT STORE
        // NOTIFY THE USER IF SAVE FAILS
        do {
            try dataController.viewContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
       
        // 4. ADD THE NEWLY CREATED PIN INTO THE PINS ARRAY
        pins.append(pin)
        
    }
    
    // MARK: - Add Region
    
    // MARK: - Reload Map View
    func reloadMapView() {
        
        if !annotations.isEmpty {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        
        
        
        for pin in pins {
            // 1. RETRIEVE LOCATION DATA FROM PERSISTENT STORE
            let lat = pin.latitude
            let long = pin.longitude
            // 2. CONFIGURE THE MKPointAnnotation
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            // 3. ADD THE ANNOTATION
            annotations.append(annotation)
            // 4. DISPLAY THE ANNOTIONS
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(self.annotations)
                self.region.center = self.center
                self.region.span = self.coordinateSpan
                self.mapView.region = self.region
                print("mapView.center.x: \(self.mapView.region.center.latitude)")
            }
        }
    }
}

