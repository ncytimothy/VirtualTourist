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
        print("\(fetchedResultsController.fetchedObjects)")
    }

  
    // MARK: Actions
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        addAnnotation(coordinate: locationCoordinate)
        reloadMapView(locationCoordinate)
    }
    
    // MARK: - Add Annoation
    func addAnnotation(coordinate: CLLocationCoordinate2D) {
        let annotation = Pin(context: dataController.viewContext)
        annotation.longitude = coordinate.longitude
        annotation.latitude = coordinate.latitude
        do {
            try dataController.viewContext.save()
        } catch {
            let alert = UIAlertController(title: "Cannot save pin", message: "Pin location cannot saved. Please try again.", preferredStyle: .alert)
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

