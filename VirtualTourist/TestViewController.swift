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
    @IBOutlet weak var deletePromptView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let promptX = deletePromptView.frame.origin.x
        deletePromptView.frame.origin.y = view.frame.size.height
        deletePromptView.frame.size.width = view.frame.size.width
        let promptHeight = deletePromptView.frame.size.height
        let promptWidth = deletePromptView.frame.size.width
        
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func verPressed(_ sender: Any) {
        mapViewIsShift = !mapViewIsShift
        print("mapViewShift: \(mapViewIsShift)")
        
        let mapX = mapView.frame.origin.x
        let mapY = mapView.frame.origin.y + 100
        let shiftMapY = mapView.frame.origin.y - 100
        let promptX = deletePromptView.frame.origin.x
        let promptY = deletePromptView.frame.origin.y
        let shiftPromptY = deletePromptView.frame.origin.y - 100
    
        
        let mapHeight = mapView.frame.size.height
        let mapWidth = mapView.frame.size.width
        let promptHeight = deletePromptView.frame.size.height
        let promptWidth = deletePromptView.frame.size.width
        
        UIView.animate(withDuration: 0.1, animations: {
            if self.mapViewIsShift {
                self.mapView.frame = CGRect(x: mapX, y: shiftMapY, width: mapWidth, height: mapHeight)
                self.deletePromptView.frame = CGRect(x: promptX, y: shiftPromptY, width: promptWidth, height: promptHeight)
            } else {
                self.mapView.frame = CGRect(x: mapX, y: mapY, width: mapWidth, height: mapHeight)
                self.deletePromptView.frame = CGRect(x: promptX, y: promptY, width: promptWidth, height: promptHeight)
            }
            
        })
    
    }
    
}
