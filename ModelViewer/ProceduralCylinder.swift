//
//  ProceduralCylinder.swift
//  ModelViewer
//
//  Created by Ethan Ave on 4/17/17.
//  Copyright © 2017 eave. All rights reserved.
//

import Foundation
import GLKit

// A cylinder can be created from a cone with the same top and bottom radius.
final class ProceduralCylinder : ProceduralCone {
    
    init(sides: Int = 20, height: Float = 1.0, radius: Float = 1.0) {
        super.init(sides: sides, height: height, topRadius: radius, bottomRadius: radius)
    }
}
