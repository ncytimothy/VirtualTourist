//
//  TestViewController.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/5/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit
import MapKit

class TestViewController: UIViewController {
    
    var mapViewIsShift = false
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func verPressed(_ sender: Any) {
//        mapViewIsShift = !mapViewIsShift
        let xPosition = mapView.frame.origin.x
    }
    
}
