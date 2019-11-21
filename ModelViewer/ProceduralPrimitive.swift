//
//  ProceduralPrimitive.swift
//  ModelViewer
//
//  Created by temp on 3/23/17.
//  Copyright © 2017 eave. All rights reserved.
//

import Foundation
import GLKit

/// Holds information for a primitive object.
struct Primitive {
    var vertices: [GLKVector3] = []
    var normals: [GLKVector3] = []
    var uv: [GLKVector2] = []
    var triangleIndices: [Int] = []
    
    func simplify() {
        //TODO
    }
}

class ProceduralPrimitive {

    var mesh: Primitive? = nil
    var colorR: Float = 0.7
    var colorG: Float = 0.5
    var colorB: Float = 0.7
    var colorA: Float = 1.0
    
    func generate() {}
    
    /// Construct the float buffer for the primitive
    func toFloatBuffer() -> [GLfloat] {
        if let mesh = self.mesh {
            var buffer: [GLfloat] = []
            var bary: GLKVector3
            for j in 0 ... mesh.triangleIndices.count - 1 {
                let index = mesh.triangleIndices[j]
                
                // Barycentric corners for drawing the wireframe in shader
                if j % 3 == 0 {
                    bary = GLKVector3.right
                } else if j % 3 == 1 {
                    bary = GLKVector3.up
                } else {
                    bary = GLKVector3.forward
                }
                buffer.append(contentsOf: [mesh.vertices[index].x, mesh.vertices[index].y, mesh.vertices[index].z,
                                           mesh.normals[index].x, mesh.normals[index].y, mesh.normals[index].z,
                                           bary.x, bary.y, bary.z,
                                           colorR, colorG, colorB, colorA])
                
            }
            
            return buffer
        }
        return []
    }
}
