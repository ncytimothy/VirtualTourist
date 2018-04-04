//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 3/27/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Properties
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    // MARK: - Set Up Fetched Results Controller
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "annotation")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFetchedResultsController()
        print("viewDidLoad called")
        debugPin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear called")
        setUpFetchedResultsController()
        debugPin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    func debugPin() {
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins {
                if let creationDate = pin.creationDate {
                    print("Creation Date: \(creationDate)")
                }
            }
        }
    }
    
    
    
    // MARK: - Actions
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = locationCoordinate.latitude
        pin.longitude = locationCoordinate.longitude
        pin.creationDate = Date()
        do {
            try dataController.viewContext.save()
        } catch {
            let alert = UIAlertController(title: "Cannot add pin", message: "Cannot add pin. Please try again later.", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
        reloadMapView(locationCoordinate)
    }
    
    @IBAction func addBabe(_ sender: Any) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = 0.0
        pin.longitude = 0.0
        pin.creationDate = Date()
        do {
            try dataController.viewContext.save()
            print("babe added!")
        } catch {
            let alert = UIAlertController(title: "Cannot add pin", message: "Cannot add pin. Please try again later.", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Reload Map View
    func reloadMapView(_ coordinate: CLLocationCoordinate2D) {
        
            let lat = coordinate.latitude
            let long = coordinate.longitude
        
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
        
            annotations.append(annotation)
        
        performUIUpdatesOnMain {
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    // MARK: - Configure longPressRecognizer
    func configureLongPressRecognizer() {
        
    }
}

// MARK: - Extension (NSFetchedResultsControllerDelegate)
extension TravelLocationsViewController: NSFetchedResultsControllerDelegate {
    
    
    
}

