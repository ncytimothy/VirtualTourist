//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/13/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: UIViewController {
    
    // MARK: - Properties
    var pin: Pin!

    override func viewDidLoad() {
        super.viewDidLoad()
         print("\(pin.coordinate) in PhotoAlbumVC")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
