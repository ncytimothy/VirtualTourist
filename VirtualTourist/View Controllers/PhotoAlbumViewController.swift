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
    
    enum CollectionViewConstants {
        static let cellsCount: Int = 21
    }
    
    enum ViewControllerConstants {
        static let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    }
    
    // Alert View Controller
    
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBOutlet weak var bottomLabel: UILabel!
    

    // Dependency Injection of DataController (Implicitly Unwrapped)
    var dataController: DataController!

    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    
    // Fetched Results Controller
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    // FETCHED RESULTS CONTROLLER PERSISTS OVER THE LIFETIME OF THE VIEW CONTROLLER
    // NEED TO SPECIFY THE MANAGED OBJECT (GENERIC TYPE)

    // Alphabet Debug Array
    let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V"]
    
// -------------------------------------------------------------------------
// MARK: - Lifecycle
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up collectionView
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
      
        
        setUpFetchedResultsController()
        
        reloadMapView()
        
        updateButtonLabel()
        
//        presentLoadingAlert()
    
        setUpCollectionViewFlowLayout()
        
        collectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        print("(pin.coordinate.latitude, pin.coordinate.longitude) = (\(pin.coordinate.latitude), \(pin.coordinate.longitude)) ")
        
        print("viewDidLoad called in PhotoVC")
        print("pin.photos.allObjects: \(pin.photos?.allObjects)")
        
     
//        downloadPhotos()
      
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         addDebugPhotos()
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
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        
        // Previously
//        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        
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

// -------------------------------------------------------------------------
// MARK: - Helpers
    fileprivate func downloadPhotos() {
        
        var downloadCount: Int = 0
        
        while downloadCount < CollectionViewConstants.cellsCount {
            print("downloadCount: \(downloadCount)")
            addPhoto()
            downloadCount += 1
        }
    }
    
    fileprivate func presentLoadingAlert() {
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        
        ViewControllerConstants.alert.view.addSubview(loadingIndicator)
        present(ViewControllerConstants.alert, animated: true, completion: nil)
        
    }
  
// -------------------------------------------------------------------------
// MARK: - Actions
    
    @IBAction func bottomButtonPressed(_ sender: Any) {

        if bottomButton.titleLabel?.text == "Remove Selected Images" {
            deleteImages { (success) in
                if success {
                    self.bottomButton.setTitle("New Collection", for: .normal)
                }
            }
        }
        
        if bottomButton.titleLabel?.text == "New Collection" {
            deleteAllImages()
//            presentLoadingAlert()
            // Make sure that the collection view is not scrollable when refreshed
            collectionView.isScrollEnabled = false
            
            downloadPhotos()
            
//            addDebugPhotos()
//            updateDebugPhotos()
            
            collectionView.isScrollEnabled = true
            
            if let imagesStored = fetchedResultsController.fetchedObjects {
                for imageStore in imagesStored {
                    print("Image UUID: \(imageStore.uuid!)")
                }
            }
        }
    }
// -------------------------------------------------------------------------
// MARK: - Delete Images
    
func deleteImages(completionHandler: @escaping(_ success: Bool) -> Void) {
    
    // UUID of selected items
    var uuidArray: [String] = []
    
    // Get all selected objects in collectionView
    if let indexPathForSelectedItems = collectionView.indexPathsForSelectedItems {
        print("indexPathSelectedItems in deleteImages: \(indexPathForSelectedItems)")
        
        
        for indexPath in indexPathForSelectedItems {
            
            // Get image to delete
            let imageToDelete = fetchedResultsController.object(at: indexPath)
            
            // Get UUID of imageToDelete
            if let uuidToDelete = imageToDelete.uuid {
                print("uuidToDelete: \(uuidToDelete)")
                uuidArray.append(uuidToDelete)
            }
            
            print("uuidArray: \(uuidArray)")
        }
        
        for uuid in uuidArray {
            
            if let imagesToDelete = fetchedResultsController.fetchedObjects {
                for imageToDelete in imagesToDelete {
                    if imageToDelete.uuid == uuid {
                        dataController.viewContext.delete(imageToDelete)
                        
                        do {
                            try dataController.viewContext.save()
                            completionHandler(true)
                        } catch {
                            print("Cannot delete photo!")
                            completionHandler(false)
                        }
                    }
                }
            }
        }
    }
}
            
    
    func deleteAllImages() {
        
        collectionView.isScrollEnabled = false
        
//        for cell in collectionView.visibleCells {
//            if let cell = cell as? ImageCollectionViewCell {
//                cell.colorOverlay.backgroundColor = UIColor.rgb(red: 55, green: 54, blue: 56, alpha: 0.85)
//                cell.loader.startAnimating()
//            }
//        }

        print("Delete All Images")
        
        if let imagesToDelete = fetchedResultsController.fetchedObjects {
            for imageToDelete in imagesToDelete {
//                    dataController.viewContext.delete(imageToDelete)
                let defaultImage = UIImage(named: "white-bg")
                let defaultImageData = UIImagePNGRepresentation(defaultImage!)
                imageToDelete.imageData = defaultImageData
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("Cannot delete image!")
                }
            }
            collectionView.isScrollEnabled = true
        }
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
        
        // 1. Retrieve Location Data from passed pin
        let lat = pin.latitude
        let long = pin.longitude
        
        // 2. Configure the MKPointAnnotation
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        // 3. Add the Annotation
        annotations.append(annotation)
        
        // 4. Adjust the region to the pin's coordinates
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        
        // 4. DISPLAY THE ANNOTATIONS
        performUIUpdatesOnMain {
            self.mapView.addAnnotations(self.annotations)
            self.mapView.region = region
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
    
    //NEEDED
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return fetchedResultsController.sections?.count ?? 1
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("fetchedResultsController.sections?[section].numberOfObjects: \(fetchedResultsController.sections?[section].numberOfObjects)")
        print("self.fetchedResultsController.fetchedObjects?.count in numberOfItemsInSection: \(self.fetchedResultsController.fetchedObjects?.count)")
        
//        if fetchedResultsController.fetchedObjects?.count == 0 {
//            return 21
//        }

    
        return fetchedResultsController.sections?[section].numberOfObjects ?? CollectionViewConstants.cellsCount
        
        //NEEDED
//        return fetchedResultsController.sections?[section].numberOfObjects ?? 21
//         return fetchedResultsController.sections?[section].numberOfObjects ?? 21
    }
    
    func addPhoto() {
        
        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            return
        }
        
        FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, dataController: dataController, pin: pin) { (success, error) in
            
            if success {
                print("Success!")
                
            }
        }
        
    }
  
    func addPhoto(_ completionHandlerForAddPhoto: @escaping (_ success: Bool) -> Void) {

        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            return
        }
        
            FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, dataController: dataController, pin: pin) { (success, error) in
                
                if success {
                    print("Success!")
                    completionHandlerForAddPhoto(true)
                }
        }
    }
    
//        FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, dataController: dataController, pin: pin, { (success, image, error) in
//
//
//            if success {
//                print("Jennifer is soooo pretty!!")
//            }
//
//
//
////            var downloadCount: Int = 0
////
////            while downloadCount < 21 {
////                if let image = image {
////                    let imageData = UIImagePNGRepresentation(image)
////                    let photo = Photo(context: self.dataController.viewContext)
////                    photo.imageData = imageData
////                    photo.creationDate = Date()
////                    photo.pin = self.pin
////
////                    do {
////                        try self.dataController.viewContext.save()
////                        downloadCount += 1
////                        print("saving...")
////                    } catch {
////                        let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment", preferredStyle: .alert)
////                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
////                        alert.addAction(okAction)
////                    }
////                }
////            }
//        })
//
//        //            FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, { (success, image, error) in
//        //
//        //                if let image = image {
//        //
//        //                    let imageData = UIImagePNGRepresentation(image)
//        //                    let photo = Photo(context: self.dataController.viewContext)
//        //                    photo.imageData = imageData
//        //
//        //
//        ////                    let image = Photo(context: self.dataController.viewContext)
//        //
//        //                    do {
//        //                        try self.dataController.viewContext.save()
//        //                        print("saving image...")
//        //                    } catch {
//        //                        let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment.", preferredStyle: .alert)
//        //                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        //                        alert.addAction(okAction)
//        //                    }
//        //
//        //                    performUIUpdatesOnMain {
//        //
//        //                        if let imageData = self.fetchedResultsController.object(at: indexPath).imageData {
//        //                            cell.imageView.image = UIImage(data: imageData)
//        //                            cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//        //                            cell.loader.stopAnimating()
//        //
//        //                        }
//        //                    }
//        //                }
//        //            })
//
//    }
    
    func updateDebugPhotos() {
        
        if let imagesToDelete = fetchedResultsController.fetchedObjects {
            for imageToDelete in imagesToDelete {
                for letter in alphabet {
                    let letter = UIImage(named: letter)
                    let letterImageData = UIImagePNGRepresentation(letter!)
                    imageToDelete.imageData = letterImageData
                    imageToDelete.pin = self.pin
                    imageToDelete.uuid = UUID().uuidString
                    do {
                        try dataController.viewContext.save()
                    } catch {
                        print("Cannot delete image!")
                    }
                }
            }
            
        }
    }
    
    func addDebugPhotos() {
        
        print("debugPhotos fRC.objects: \(String(describing: fetchedResultsController.fetchedObjects))")
        print("collectionViewCells: \(collectionView.visibleCells)")
        
        // Previously, to prevent repetition, think of another way to do it
        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            return
        }
        
        print("Jen Brice")
        
        for letter in alphabet {
            print("downloading")
            let debugImage = UIImage(named: letter)
            if let debugImage = debugImage {
                let imageData = UIImagePNGRepresentation(debugImage)
                let photo = Photo(context: self.dataController.viewContext)
                photo.imageData = imageData
                photo.pin = self.pin
                photo.uuid = UUID().uuidString
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
    
    func addDebugPhotos(completionHandler: @escaping (_ success: Bool) -> Void) {
        
        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            return
        }
        
        for letter in alphabet {
            print("downloading")
            let debugImage = UIImage(named: letter)
            if let debugImage = debugImage {
                let imageData = UIImagePNGRepresentation(debugImage)
                let photo = Photo(context: self.dataController.viewContext)
                photo.imageData = imageData
                photo.pin = self.pin
                print("(photo.pin.coordinates.latitude, photo.pin.coordinate.longitude): (\(self.pin.coordinate.latitude), \(self.pin.coordinate.longitude))")
                
                do {
                    try self.dataController.viewContext.save()
                    print("saving JENN")
                    completionHandler(true)
                } catch {
                    let alert = UIAlertController(title: "Cannot save photo", message: "Your photo cannot be saved at the moment", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    completionHandler(false)
                }
            }
        }
    }
    

    fileprivate func updateCell(_ cell: ImageCollectionViewCell, _ imageData: Data) {
        cell.imageView.image = UIImage(data: imageData)
//        cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
        cell.loader.stopAnimating()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt called")
        var debugCounter = 1

        
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCollectionViewCell
        
    
 
  
        
      
       
    
//        cell.colorOverlay.backgroundColor = cell.isChecked ? selectedOverlayColor : deselectedOverlayColor
//        cell.checkmark.isHidden = cell.isChecked ? false : true
        
// -------------------------------------------------------------------------
//        print("indexPath: \(indexPath)")
//
//
        
    //GUARD TO BE USED AND NEEDED
        guard !(self.fetchedResultsController.fetchedObjects?.isEmpty)! else {

            return cell
        }
//
        // Download Photo Block
        
        let aPhoto = self.fetchedResultsController.object(at: indexPath)

        print("self.fetchedResultsController.fetchedObjects?.count in cellForItemAt: \(self.fetchedResultsController.fetchedObjects?.count)")
        
        if let imageCreationDate = aPhoto.creationDate {
            print("Image Creation Date: \(imageCreationDate)")
        }

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
        
          print("indexPathsForSelectedItems at didSelectItemAt: \(collectionView.indexPathsForSelectedItems)")
      
        updateSelectUI(cell: cell)
        updateButtonLabel()
      
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
        updateButtonLabel()
        

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
        
        if (collectionView.indexPathsForSelectedItems?.isEmpty)! {
            bottomButton.setTitle("New Collection", for: .normal)
        } else {
            bottomButton.setTitle("Remove Selected Images", for: .normal)
        }
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
        
        print("indexPath in controller:didChange anObject: \(indexPath)")
         print("newIndexPath in controller:didChange anObject: \(newIndexPath)")
        

        switch type {
        case .insert:
            print("JENNN")
            // Previously
            collectionView.insertItems(at: [newIndexPath!])
            
            
            
//            collectionView.reloadItems(at: [newIndexPath!])
            if let fetchedObjects = controller.fetchedObjects {
                if fetchedObjects.count == CollectionViewConstants.cellsCount {
                    collectionView.isScrollEnabled = true
                    ViewControllerConstants.alert.dismiss(animated: true, completion: nil)
                    print("Scroll Enabled!")
                }
            }
            
            
            print("newIndexPath: \(newIndexPath!)")
        
//            cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//            cell.loader.stopAnimating()
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            collectionView.reloadItems(at: [newIndexPath!])
            break
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





