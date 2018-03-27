//
//  GCDMain.Swift
//  VirtualTourist
//
//  Created by Timothy Ng on 3/27/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping() -> Void) {
    
    DispatchQueue.main.async {
        updates()
    }
}
