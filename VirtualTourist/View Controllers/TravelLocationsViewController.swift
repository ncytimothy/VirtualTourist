//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 3/27/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit
import MapKit
// Import Core Data
import CoreData

class TravelLocationsViewController: UIViewController {

// MARK: - Properties
    @IBOutlet var mapView: MKMapView!

    // Data Controller property from AppDelegate.swift
    var dataController: DataController!

    // MKAnnoations Array
    var annotations = [MKAnnotation]()
    var mapViewIsShift = false
    
    @IBOutlet weak var deletePromptView: UIView!
    var deleteLabel: UILabel!
    
    // Fetched Results Controller, specified with an entity
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    // Selected Point Annotation
    var selectedAnnotation: MKPointAnnotation?
    
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
    
// MARK: - Fetched Results Controller
    fileprivate func setUpFetchedResultsController() {

        // 1. Create Fetch Request
        // Fetch Requests are Generic Types
        // You specify the "Type" (entity name in angel brackets) in parameter
        // Specifying the "Type" parameter will make the fetch request
        // Work with a specifc managed object subclass
        // Call the type's fetchRequest() method
        // Pin.fetchRequest() returns a fetch request initialized with the entity
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()

        // 2. Configure the fetch request by adding a sort rule
        // fetchRequest.sortDescriptors property takes an array of sort descriptors
        // .sortDescriptors **MUST** be set on any NSFetchedResultsController instance
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // 3. Instantiate fetched results controller with fetch request
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")

        // 4. Set the fetched results controller delegate property to self
        fetchedResultsController.delegate = self

        // 5. Perform fetch to load data and start tracking
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch cannot be performed: \(error.localizedDescription)")
        }

        // 6. Remove the Fetched Results Controller when the view disappears
        // 7. Implement delegate confromance + methods for fetched results controller for UI updates (in an Extension)

    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setUpFetchedResultsController()
        
        // Set up mapView Constraints
        
        // Set right button navigation item to system default edit button item
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        configureDeletePrompt()
        configureDeleteLabel()
        
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
        reloadMapView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - Edit Delete View Animation
    fileprivate func editAnimation(_ mapViewIsShift: Bool) {
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
    
    
    // MARK: - System Default Method for Edit Button Item
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Toggle the mapViewIsShift boolean
        mapViewIsShift = !mapViewIsShift
        editAnimation(mapViewIsShift)
        
    }
    
//     MARK: - Actions
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        addPin(coordinate: locationCoordinate)
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
    }
}

// MARK: - NSFetchedResultsController Delegate
extension TravelLocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes observed in the TravelLocationsViewController should be for Pin instances")
        }
        
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
        case .delete:
            mapView.removeAnnotation(pin)
        case .update:
            mapView.removeAnnotation(pin)
            mapView.addAnnotation(pin)
        case .move:
            fatalError("How did we move a point? We have a stable sort")
        }
    }
}

extension TravelLocationsViewController: MKMapViewDelegate {
    
    func reloadMapView() {
        
        if !annotations.isEmpty {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        
        if let pins = fetchedResultsController.fetchedObjects {
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
    
    // CONFIGURE MKAnnotation VIEW
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false
            pinView?.pinTintColor = .red
            pinView?.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        let selectedAnnotation = view.annotation
        let selectedAnnotationLat = selectedAnnotation?.coordinate.latitude
        let selectedAnnotationLong = selectedAnnotation?.coordinate.longitude
        var selectedPin: Pin
        
        if let result = fetchedResultsController.fetchedObjects {
            
            for pin in result {
                if pin.latitude == selectedAnnotationLat && pin.longitude == selectedAnnotationLong {
                    selectedPin = pin
                    prepare(pin: selectedPin) { (photoAlbumVC) in
                        self.navigationController?.pushViewController(photoAlbumVC, animated: true)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Prepare for Segue to Photo Album VC
    func prepare(pin: Pin, _ completionHandler: @escaping (_ photoAlbumVC: PhotoAlbumViewController) -> Void) {
         let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumVC") as! PhotoAlbumViewController
        photoAlbumVC.pin = pin
        photoAlbumVC.dataController = dataController
        completionHandler(photoAlbumVC)
    }
}

