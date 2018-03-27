//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 3/27/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit

class TravelLocationsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    var count: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions
    @IBAction func longPressOnMap(_ sender: Any) {
        print("Long pressed Veronica \(count)!")
        count += 1
    }
    
    // MARK: - Configure longPressRecognizer
    func configureLongPressRecognizer() {
        
    }
}

