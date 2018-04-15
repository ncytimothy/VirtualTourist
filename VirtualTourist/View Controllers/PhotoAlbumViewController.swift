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
    
    // MARK: - Properties
    var pin: Pin!
    @IBOutlet weak var collectionView: UICollectionView!
    // Dependency Injection of DataController (Implicitly Unwrapped)
    var dataController: DataController!
    
    // (Currently) Downloaded Images Array
    var images: [UIImage?] = []
    

    var annotations = [MKAnnotation]()
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var imageView: UIImageView!
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        print("\(pin.coordinate) in PhotoAlbumVC")
        reloadMapView()
        FlickrClient.sharedInstance().downloadPhotos(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude) { (success, images, error) in
            
            if success {
                self.images = images
                print("images.count: \(images.count)")
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    

    

}

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

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("images.count: \(images.count)")
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images[(indexPath.row)]
        return cell
    }
    
}
