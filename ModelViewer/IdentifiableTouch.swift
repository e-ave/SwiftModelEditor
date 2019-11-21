//
//  IdentifiableTouch.swift
//  ModelViewer
//
//  Created by Ethan Ave on 4/6/17.
//  Copyright © 2017 eave. All rights reserved.
//

import UIKit

// A class used to track the movement of a touch
class IdentifiablePoint {
    var origin: CGPoint
    var touch: UITouch
    
    init(origin: CGPoint, touch: UITouch) {
        self.origin = origin
        self.touch = touch
    }
    
}
