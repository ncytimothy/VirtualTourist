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
        mapViewIsShift = !mapViewIsShift
        print("mapViewShift: \(mapViewIsShift)")
        let xPosition = mapView.frame.origin.x
        let yPosition = mapView.frame.origin.y + 100
        let shiftYPosition = mapView.frame.origin.y - 100
        
        let height = mapView.frame.size.height
        let width = mapView.frame.size.width
        
        UIView.animate(withDuration: 0.1, animations: {
            if self.mapViewIsShift {
                self.mapView.frame = CGRect(x: xPosition, y: shiftYPosition, width: width, height: height)
            } else {
                self.mapView.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
            }
            
        })
    
    }
    
}
