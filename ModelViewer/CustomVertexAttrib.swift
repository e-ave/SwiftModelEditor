//
//  CustomVertexAttrib.swift
//  ModelViewer
//
//  Created by Ethan Ave on 3/28/17.
//  Copyright © 2017 eave. All rights reserved.
//

import GLKit

// Custom named vertex attributes program-specific attributes
@available(iOS 5.0, *)
public enum CustomVertexAttrib : GLuint {

    case barycentric = 5
    
    case selectedTriangle
}

