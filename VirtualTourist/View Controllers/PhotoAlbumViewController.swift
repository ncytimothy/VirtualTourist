//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/13/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
// -------------------------------------------------------------------------
// MARK: - Properties
    
    // Resuse Cell Id
    let cellId = "cellId"
    
    // Pin Injection from TravelLocationsVC
    var pin: Pin!
    
    // Map Annotations
    var annotations = [MKAnnotation]()
    
//    // Placeholder Loader
//    let loader: UIActivityIndicatorView = {
//        let loader = UIActivityIndicatorView()
//        loader.color = UIColor.red
//        return loader
//    }()
    
    // Dependency Injection of DataController (Implicitly Unwrapped)
    var dataController: DataController!
//    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    
    // Fetched Results Controller
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    

   
    // (Currently) Downloaded Images Array
    var image: UIImage?
    
// -------------------------------------------------------------------------
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        setUpFetchedResultsController()
        print("\(pin.coordinate) in PhotoAlbumVC")
        reloadMapView()
    
        // Flow Layout
        let layout = UICollectionViewFlowLayout()
        let space: CGFloat = 3.0
        let dimension = (view.frame.width - (2 * space)) / 3.0
        
        layout.itemSize = CGSize(width: 125, height: 125)
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView.collectionViewLayout = layout
        
        
        collectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        FlickrClient.sharedInstance().downloadPhotos(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, { (success, images, error) in
            print("flickr client called")
            if success {
                print("successful download!")
            }
        })
        
        FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude) { (success, image, error) in
            print("flickr client called")
            if success {
                print("successful download!")
                self.image = image
                
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
      
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Removes fetchedResultsController when view disappears to unsubscribe to notifications for changes in the dataController's view context
        fetchedResultsController = nil
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Fetched Results Controller Setup
    
    fileprivate func setUpFetchedResultsController() {
        
        // 3a. Create Fetch Request
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        // 3b. Configure the Fetch Request with Sort Rules
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // 3c. Instantiate the fetchResultsController using fetchRequest
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // 3d. Perform Fetch to Load Data
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // Fatal Error is Thrown if Fetch Fails
            fatalError("The fetch cannot be performed: \(error.localizedDescription)")
        }
        
        // 3e. Set the fetched results controller delegate property to self
        // FETCHED RESULTS CONTROLLER TRACKS CHANGES
        // TO RESPONSE TO THOSE CHANGES, NEED TO IMPLEMENT SOME DELEGATE METHODS
        fetchedResultsController.delegate = self
        
    }
    
}



// -------------------------------------------------------------------------
// MARK: - MKMapViewDelegate Methods

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func reloadMapView() {
        
        if !annotations.isEmpty {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        
        // 1. RETRIEVE LOCATION DATA FROM PASSED PIN
        let lat = pin.latitude
        let long = pin.longitude
        
        // 2. CONFIGURE THE MKPointAnnotation
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        // 3. ADD THE ANNOTATION
        annotations.append(annotation)
        
        // 4. DISPLAY THE ANNOTATIONS
        performUIUpdatesOnMain {
            self.mapView.addAnnotations(self.annotations)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false
            pinView?.tintColor = .red
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
}

// -------------------------------------------------------------------------
// MARK: - UICollectionViewDataSource, Delegate and FlowLayout

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("images.count: \(images.count)")
        return 21
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt called")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCollectionViewCell
        
//        cell.contentView.addSubview(cell.loader)

//        if let image = image {
////            cell.backgroundColor = UIColor.black
//            cell.imageView.image = image
//        }
        
        cell.imageView.image = image ?? nil
        
        //TODO: Constraints for ImageView
        
        return cell
    }
}




