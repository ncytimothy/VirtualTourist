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

class PhotoAlbumViewController: UIViewController {
    
// -------------------------------------------------------------------------
// MARK: - Properties
    
    // Resuse Cell Id
    let cellId = "cellId"
    
    // Pin Injection from TravelLocationsVC
    var pin: Pin!
    
    // Map Annotations
    var annotations = [MKAnnotation]()
    
    // Fixed Collection View Cells Count
    let cellsCount: Int = 21
    
    // Selected Cells Count
    var selectedCellsCount: Int = 0
    
    @IBOutlet weak var bottomButton: UIButton!
    
    
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
    // FETCHED RESULTS CONTROLLER PERSISTS OVER THE LIFETIME OF THE VIEW CONTROLLER
    // NEED TO SPECIFY THE MANAGED OBJECT (GENERIC TYPE)

    // (Currently) Downloaded Images Array
    var image: UIImage?
    var images: [UIImage?] = []
    
// -------------------------------------------------------------------------
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        setUpFetchedResultsController()
        print("\(pin.coordinate) in PhotoAlbumVC")
        reloadMapView()
    
        setUpCollectionViewFlowLayout()
        
        collectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        print("(pin.coordinate.latitude, pin.coordinate.longitude) = (\(pin.coordinate.latitude), \(pin.coordinate.longitude)) ")
        
        print("viewDidLoad called in PhotoVC")
        print("pin.photos.allObjects: \(pin.photos?.allObjects)")
        
     
        
  
// -------------------------------------------------------------------------
        addPhotos()
// -------------------------------------------------------------------------
        
//        if (pin.photos?.allObjects.isEmpty)! {
//            FlickrClient.sharedInstance().downloadPhotos(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, { (success, images, error) in
//
//                if success {
//                    print("download success!")
//                    for image in images {
//                        if let image = image {
//                            let imageData = UIImagePNGRepresentation(image)
//                            let photo = Photo(context: self.dataController.viewContext)
//                            photo.imageData = imageData
//
//
//                            do {
//                                try self.dataController.viewContext.save()
//                                print("saving JENN")
//                            } catch {
//                                let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment", preferredStyle: .alert)
//                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                                alert.addAction(okAction)
//                            }
//
//                        }
//                    }
//                }
//            })
//        }
        
//        FlickrClient.sharedInstance().downloadPhotos(latitude: self.pin.coordinate.latitude, longitude: self.pin.coordinate.longitude, { (success, images, error) in
//            print("flickr client called")
//            if success {
//                print("successful download")
//                self.images = images
//                print("images in VC: \(images)")
//
//                performUIUpdatesOnMain {
//                    self.collectionView.reloadData()
//                }
//
//            }
//        })
        
        
//
//        FlickrClient.sharedInstance().downloadPhotos(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, { (success, images, error) in
//            print("flickr client called")
//            if success {
//                print("successful download!")
//                self.images = images
//            }
//        })

//        FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude) { (success, image, error) in
//            print("flickr client called")
//            if success {
//                print("successful download!")
//                self.image = image
//
//                performUIUpdatesOnMain {
//                    self.collectionView.reloadData()
//                }
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        
        print("viewWillAppear called in PhotoVC")
        
      
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
        
        // 3b. Filter to right pin
        if let pin = pin {
            let predicate = NSPredicate(format: "pin == %@", pin)
            fetchRequest.predicate = predicate
        }
        
        // 3b. Configure the Fetch Request with Sort Rules
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // 3c. Instantiate the fetchResultsController using fetchRequest
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "cellPhotos")
        
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("fetchedResultsController.sections?[section].numberOfObjects: \(fetchedResultsController.sections?[section].numberOfObjects)")
        print("self.fetchedResultsController.fetchedObjects?.count in numberOfItemsInSection: \(self.fetchedResultsController.fetchedObjects?.count)")
        
//        if fetchedResultsController.fetchedObjects?.count == 0 {
//            return 21
//        }

        return fetchedResultsController.sections?[section].numberOfObjects ?? 21
    }
    
    func addPhoto() {
        
        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            return
        }
        
        FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.longitude, longitude: pin.coordinate.longitude, { (success, image, error) in
            
            var downloadCount: Int = 0
            
            while downloadCount < 21 {
                if let image = image {
                    let imageData = UIImagePNGRepresentation(image)
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageData = imageData
                    photo.pin = self.pin
                    
                    do {
                        try self.dataController.viewContext.save()
                        downloadCount += 1
                        print("saving...")
                    } catch {
                        let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                    }
                }
            }
        })
        
        //            FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, { (success, image, error) in
        //
        //                if let image = image {
        //
        //                    let imageData = UIImagePNGRepresentation(image)
        //                    let photo = Photo(context: self.dataController.viewContext)
        //                    photo.imageData = imageData
        //
        //
        ////                    let image = Photo(context: self.dataController.viewContext)
        //
        //                    do {
        //                        try self.dataController.viewContext.save()
        //                        print("saving image...")
        //                    } catch {
        //                        let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment.", preferredStyle: .alert)
        //                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //                        alert.addAction(okAction)
        //                    }
        //
        //                    performUIUpdatesOnMain {
        //
        //                        if let imageData = self.fetchedResultsController.object(at: indexPath).imageData {
        //                            cell.imageView.image = UIImage(data: imageData)
        //                            cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
        //                            cell.loader.stopAnimating()
        //
        //                        }
        //                    }
        //                }
        //            })
        
        
        
    }
    
    
    fileprivate func addPhotos() {
        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            return
        }
        
        
            FlickrClient.sharedInstance().downloadPhotos(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, { (success, images, error) in
                
                
                
                if success {
                    print("download success!")
                    
                    
                    for image in images {
                        if let image = image {
                            let imageData = UIImagePNGRepresentation(image)
                            let photo = Photo(context: self.dataController.viewContext)
                            photo.imageData = imageData
                            photo.pin = self.pin
                            print("(photo.pin.coordinates.latitude, photo.pin.coordinate.longitude): (\(self.pin.coordinate.latitude), \(self.pin.coordinate.longitude))")
                            
                            do {
                                try self.dataController.viewContext.save()
                                print("saving JENN")
                              
                              
                            } catch {
                                let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                            }
                            
                        }
                    }
                }
            })
    }
    
    fileprivate func updateCell(_ cell: ImageCollectionViewCell, _ imageData: Data) {
        cell.imageView.image = UIImage(data: imageData)
//        cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
        cell.loader.stopAnimating()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt called")
//        collectionView.isScrollEnabled = false
        
      
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCollectionViewCell
       
    
//        cell.colorOverlay.backgroundColor = cell.isChecked ? selectedOverlayColor : deselectedOverlayColor
//        cell.checkmark.isHidden = cell.isChecked ? false : true
        
// -------------------------------------------------------------------------
//        print("indexPath: \(indexPath)")
//
//
        let aPhoto = self.fetchedResultsController.object(at: indexPath)
        
        print("self.fetchedResultsController.fetchedObjects?.count in cellForItemAt: \(self.fetchedResultsController.fetchedObjects?.count)")

        if let imageData = aPhoto.imageData {
            let image = UIImage(data: imageData)
            cell.imageView.image = image
            cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
            
//            print("cell.isSelected: \(cell.isSelected)")
            
            updateSelectUI(cell: cell)
            
            cell.loader.stopAnimating()
        }
        
          return cell
//
// -------------------------------------------------------------------------
//        guard !images.isEmpty else {
//            return cell
//        }
        
//        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
//
//            let aPhoto = self.fetchedResultsController.object(at: indexPath)
//
//            performUIUpdatesOnMain {
//                if let imageData = aPhoto.imageData {
//                    self.updateCell(cell, imageData)
//                }
//            }
//
//            return cell
//        }
//
//        FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, { (success, image, error) in
//
//            if let image = image {
//
//                let imageData = UIImagePNGRepresentation(image)
//                let photo = Photo(context: self.dataController.viewContext)
//                photo.imageData = imageData
//                photo.pin = self.pin
//
//                do {
//                    try self.dataController.viewContext.save()
//                    if let imageData = self.fetchedResultsController.object(at: indexPath).imageData {
//                          self.updateCell(cell, imageData)
//                    }
//                } catch {
//                    let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment.", preferredStyle: .alert)
//                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    alert.addAction(okAction)
//                }
//            }
//
//        })
        
       
        
        
        
        
        
// -------------------------------------------------------------------------
//    FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, { (success, image, error) in
//
//        var downloadCount: Int = 0
//
//        while downloadCount <= 21 {
//            if let image = image {
//
//                let imageData = UIImagePNGRepresentation(image)
//                let photo = Photo(context: self.dataController.viewContext)
//                photo.imageData = imageData
//
//                do {
//                    try self.dataController.viewContext.save()
//                    print("saving image...")
//                    downloadCount += 1
//                }catch {
//                    let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment.", preferredStyle: .alert)
//                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    alert.addAction(okAction)
//                }
//
//                performUIUpdatesOnMain {
//                    //                            print("indexPath: \(indexPath)")
//                    if let imageData = self.fetchedResultsController.object(at: indexPath).imageData {
//                        cell.imageView.image = UIImage(data: imageData)
//                        cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//                        cell.loader.stopAnimating()
//                    }
//                }
//            }
//        }
//    })
// -------------------------------------------------------------------------
        
//            FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, { (success, image, error) in
//
//                if let image = image {
//
//                    let imageData = UIImagePNGRepresentation(image)
//                    let photo = Photo(context: self.dataController.viewContext)
//                    photo.imageData = imageData
//                    photo.pin = self.pin
//
////                    let image = Photo(context: self.dataController.viewContext)
//
//                    do {
//                        try self.dataController.viewContext.save()
//                        print("saving image...")
//                    } catch {
//                        let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment.", preferredStyle: .alert)
//                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alert.addAction(okAction)
//                    }
//
//                    performUIUpdatesOnMain {
//
//                        if let imageData = self.fetchedResultsController.object(at: indexPath).imageData {
//                            cell.imageView.image = UIImage(data: imageData)
//                            cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//                            cell.loader.stopAnimating()
//
//                        }
//                    }
//                }
//            })
// -------------------------------------------------------------------------
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt: called")

        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        let selectedOverlayColor = UIColor.rgb(red: 242, green: 242, blue: 242, alpha: 0.85)
      
        updateSelectUI(cell: cell)
      
//        cell.checkmark.isHidden = cell.isChecked ? false : true

//        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
//        print("cell.isChecked: \( cell.isChecked)")
//        cell.isChecked = !cell.isChecked
//        let selectedOverlayColor = UIColor.rgb(red: 242, green: 242, blue: 242, alpha: 0.85)
//        let deselectedOverlayColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//
//        cell.colorOverlay.backgroundColor = cell.isChecked ? selectedOverlayColor : deselectedOverlayColor
//        cell.checkmark.isHidden = cell.isChecked ? false : true
//

    }
//
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
        
        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        let deselectedOverlayColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
        
        updateSelectUI(cell: cell)
        

    }
    
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        <#code#>
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        print("didHighlightItemAt indexPath called")
//    }
//
    func updateButtonLabel() {
        print("selectedCellsCount: \(selectedCellsCount)")
        
    }
    
 
    fileprivate func setUpCollectionViewFlowLayout() {
        // Flow Layout
        let layout = UICollectionViewFlowLayout()
        let space: CGFloat = 3.0
        let dimension = (view.frame.width - (2 * space)) / 3.0
        
        layout.itemSize = CGSize(width: 125, height: 125)
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView.collectionViewLayout = layout
       
    }
}

// -------------------------------------------------------------------------
// MARK: - NSFetchedResultsControllerDelegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("JENNN")
            collectionView.insertItems(at: [newIndexPath!])
         
            
        
//            cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//            cell.loader.stopAnimating()
            break
        case .delete:
            break
        case .update:
            collectionView.reloadItems(at: [newIndexPath!])
        default:
            break
        }
    }
    
}

// -------------------------------------------------------------------------
// MARK: - Helpers
extension PhotoAlbumViewController {
    
    func updateSelectUI(cell: ImageCollectionViewCell) {
        
        let selectedOverlayColor = UIColor.rgb(red: 242, green: 242, blue: 242, alpha: 0.85)
        let deselectedOverlayColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
        
        if cell.isSelected {
            cell.colorOverlay.backgroundColor = selectedOverlayColor
            cell.checkmark.isHidden = false
        } else {
            cell.colorOverlay.backgroundColor = deselectedOverlayColor
            cell.checkmark.isHidden = true
        }
    }
    
}





