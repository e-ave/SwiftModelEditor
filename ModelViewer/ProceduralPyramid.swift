//
//  ProceduralPyramid.swift
//  ModelViewer
//
//  Created by Ethan Ave on 4/17/17.
//  Copyright © 2017 eave. All rights reserved.
//

import Foundation
import GLKit

final class ProceduralPyramid : ProceduralCone {
    
    init() {
        super.init(sides: 3, height: height, topRadius: topRadius, bottomRadius: bottomRadius)
    }
}
