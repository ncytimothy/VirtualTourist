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
    
    // MARK: - Properties
    var mapViewIsShift = false
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePromptView: UIView!
    var label: UILabel!
    
    
    // MARK: - Configure Delete Prompt
    fileprivate func configureDeletePrompt() {
        deletePromptView.frame.origin.y = view.frame.size.height
        deletePromptView.frame.size.width = view.frame.size.width
    }
    
    fileprivate func configureDeleteLabel() {
        /**
        Create a label for the delete pins prompt
        * Initially defining the label's frame is merely for initialization
        */
        let labelRect = CGRect(x: 0, y: 0, width: 200, height: 21)
        label = UILabel(frame: labelRect)
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "Tap Pins to Delete"
        label.textColor = .white
        self.label.textAlignment = .center
        self.view.addSubview(self.label)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        configureDeletePrompt()
        configureDeleteLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        mapViewIsShift = !mapViewIsShift
        print("mapViewShift: \(mapViewIsShift)")
        
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
                self.label.frame = CGRect(x: promptX, y: shiftPromptY, width: promptWidth, height: promptHeight)
            } else {
                self.mapView.frame = CGRect(x: mapX, y: mapY, width: mapWidth, height: mapHeight)
                self.deletePromptView.frame = CGRect(x: promptX, y: promptY, width: promptWidth, height: promptHeight)
                self.label.frame = CGRect(x: promptX, y: promptY, width: promptWidth, height: promptHeight)
            }
            
        })
    }
}
