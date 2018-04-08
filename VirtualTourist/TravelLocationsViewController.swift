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
    var mapViewIsShift = false
    @IBOutlet weak var deletePromptView: UIView!
    var deleteLabel: UILabel!
    var annotationToDelete: MKAnnotation!
    
    // FETCH REQUEST
    // SELECTS INTERESTED DATA
    // LOADS THE DATA FROM PERSISTENT STORE INTO THE CONTEXT
    // MUST BE CONFIGURED WITH AN ENTITY TYPE
    // CAN OPTIONALLY INCLUDE FILTERING AND SORTING
    
    // MARK: Configure Delete Prompt
    fileprivate func configureDeletePrompt() {
        /*
        * Set deletePromptView starting origin (in y) at the view's height
        * Set deletePromptView width to the view's width
        */
        deletePromptView.frame.origin.y = view.frame.size.height
        deletePromptView.frame.size.width = view.frame.size.width
    }
    
    // MARK: - Configure Delete Label
    fileprivate func configureDeleteLabel() {
        /**
        * Create a label for the delete pins prompt
        * Initially defining the label's frame is merely for initialization
        */
        let deleteLabelRect = CGRect(x: 0, y: 0, width: 200, height: 21)
        deleteLabel = UILabel(frame: deleteLabelRect)
        deleteLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        deleteLabel.text = "Tap Pins to Delete"
        deleteLabel.textColor = .white
        deleteLabel.textAlignment = .center
        self.view.addSubview(deleteLabel)
    }
    
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
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        // 2. CONFIGURE FETCH REQUEST BY ADDING A SORT RULE
        // fetchRequest.sortDescriptors property takes an array of sort descriptors
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // 3. USE THE FETCH REQUEST
        // ASK A CONTEXT TO EXECUTE THE REQUEST
        // ASK DATA CONTROLLER'S VIEW CONTEXT (PERSISTENT CONTROLLER'S VIEW CONTEXT)
        // .fetch() CAN THROW AN ERROR
        // SAVE THE RESULTS ONLY IF THE FETCH IS SUCCESSFUL
        // USE try? TO CONVERT THE ERROR INTO AN OPTIONAL
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            // IF FETCH REQUEST SUCCESSFUL, STORE THE RESULT IN THE ARRAY FOR PINS
            pins = result
            //TODO: RELOAD MAPVIEW
           reloadMapView()
        }
        // Set right button navigation item to system default edit button item
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        configureDeletePrompt()
        configureDeleteLabel()
        
        
    }

    // MARK: - System Default Method for Edit Button Item
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Toggle the mapViewIsShift boolean
        mapViewIsShift = !mapViewIsShift
        
        // Set mapView, deletePromptView shift points to 100
        let mapX = mapView.frame.origin.x
        let mapY = mapView.frame.origin.y + 100
        let shiftMapY = mapView.frame.origin.y - 100
        
        let promptX = deletePromptView.frame.origin.x
        let promptY = view.frame.size.height
        let shiftPromptY = deletePromptView.frame.origin.y - 100
        
        let mapHeight = mapView.frame.size.height
        let mapWidth = mapView.frame.size.width
        
        let promptHeight = deletePromptView.frame.size.height
        let promptWidth = deletePromptView.frame.size.width
        
        UIView.animate(withDuration: 0.1, animations: {
            if self.mapViewIsShift {
                self.mapView.frame = CGRect(x: mapX, y: shiftMapY, width: mapWidth, height: mapHeight)
                self.deletePromptView.frame = CGRect(x: promptX, y: shiftPromptY, width: promptWidth, height: promptHeight)
                self.deleteLabel.frame = CGRect(x: promptX, y: shiftPromptY, width: promptWidth, height: promptHeight)
            } else {
                self.mapView.frame = CGRect(x: mapX, y: mapY, width: mapWidth, height: mapHeight)
                self.deletePromptView.frame = CGRect(x: promptX, y: promptY, width: promptWidth, height: promptHeight)
                self.deleteLabel.frame = CGRect(x: promptX, y: promptY, width: promptWidth, height: promptHeight)
            }
        })
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
    
    // MARK: - didSelectAnnotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("view.annonation: \(String(describing: view.annotation))")
        annotationToDelete = view.annotation
        removeAnnotation()
    }
    
    // MARK: - removeAnnotation
    func removeAnnotation() {
        print("removing annotation...")
        print("pin[0]: \(pins[0])")
        
        let pinToDelete = Pin(context: dataController.viewContext)
        
        for pin in pins {
            if pin.longitude == annotationToDelete.coordinate.longitude &&
               pin.latitude == annotationToDelete.coordinate.latitude {
                pinToDelete.creationDate = pin.creationDate
            }
        }

        pinToDelete.longitude = annotationToDelete.coordinate.longitude
        pinToDelete.latitude = annotationToDelete.coordinate.latitude

        dataController.viewContext.delete(pinToDelete)
        try? dataController.viewContext.save()
        performUIUpdatesOnMain {
            self.reloadMapView()
        }
    }
    
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
            }
        }
    }
}

