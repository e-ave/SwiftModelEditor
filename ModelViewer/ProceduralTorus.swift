//
//  ProceduralTorus.swift
//  ModelViewer
//
//  Created by temp on 3/25/17.
//  Copyright © 2017 eave. All rights reserved.
//
// Ported from: http://wiki.unity3d.com/index.php/ProceduralPrimitives#C.23_-_Torus
// https://creativecommons.org/licenses/by-sa/3.0/

import Foundation
import GLKit

final class ProceduralTorus : ProceduralPrimitive {
    var radius1: Float = 1.0
    var radius2: Float = 0.3
    var nbRadSeg: Int = 24
    var nbSides: Int = 18
    
    init(radius1: Float = 1.0, radius2: Float = 0.3, nbRadSeg: Int = 24, nbSides: Int = 18) {
        self.radius1 = radius1
        self.radius2 = radius2
        self.nbSides = nbSides
        self.nbRadSeg = nbRadSeg
    }
    
    override internal func generate() {
        var vertices: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: (nbRadSeg + 1) * (nbSides + 1))
        let _2pi: Float = Float.pi * 2.0
        for seg in 0 ... nbRadSeg {
            let currSeg: Int = seg  == nbRadSeg ? 0 : seg
            
            let t1: Float = Float(currSeg) / Float(nbRadSeg) * _2pi
            let r1: GLKVector3 = GLKVector3Make(cos(t1) * radius1, 0, sin(t1) * radius1)
            
            for side in 0 ... nbSides {
                let currSide: Int = side == nbSides ? 0 : side
                
                //let normal: GLKVector3 = GLKVector3CrossProduct(r1, GLKVector3Make(0, 1, 0))
                let t2: Float = Float(currSide) / Float(nbSides) * _2pi
                
                
                let r2: GLKVector3 = GLKQuaternionRotateVector3(GLKQuaternionMakeWithAngleAndVector3Axis(-t1, GLKVector3.up), GLKVector3Make(sin(t2) * radius2, cos(t2) * radius2, 0))
                
                vertices[side + seg * (nbSides + 1)] = r1 + r2
            }
        }
        
        // Normals
        var normals: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: vertices.count)
        for seg in 0 ... nbRadSeg {
            let currSeg: Int = seg  == nbRadSeg ? 0 : seg
            
            let t1: Float = Float(currSeg) / Float(nbRadSeg) * _2pi
            let r1: GLKVector3 = GLKVector3Make(cos(t1) * radius1, 0, sin(t1) * radius1)
            
            for side in 0 ... nbSides {
                normals[side + seg * (nbSides + 1)] = (vertices[side + seg * (nbSides+1)] - r1).normalized
            }
        }
        
        // UVs
        var uvs: [GLKVector2] = [GLKVector2](repeating: GLKVector2.zero, count: vertices.count)
        for seg in 0 ... nbRadSeg {
            for side in 0 ... nbSides {
                uvs[side + seg * (nbSides + 1)] = GLKVector2Make(Float(seg) / Float(nbRadSeg), Float(side) / Float(nbSides))
            }
        }
        
        // Triangles
        let nbFaces: Int = vertices.count
        let nbTriangles: Int = nbFaces * 2
        let nbIndexes: Int = nbTriangles * 3
        var triangles: [Int] = [Int](repeating: 0, count: nbIndexes)
        var i: Int = 0
        for seg in 0 ... nbRadSeg {
            for side in 0 ... nbSides - 1 {
                let current: Int = side + seg * (nbSides + 1)
                let next: Int = side + (seg < (nbRadSeg) ? (seg + 1) * (nbSides + 1) : 0)
                
                if i < triangles.count - 6  {
                    triangles[i++] = current
                    triangles[i++] = next
                    triangles[i++] = next + 1
                    
                    triangles[i++] = current
                    triangles[i++] = next + 1
                    triangles[i++] = current + 1
                }
            }
        }
        mesh = Primitive()
        mesh?.vertices = vertices
        mesh?.normals = normals
        mesh?.triangleIndices = triangles
        mesh?.uv = uvs
    }
    
}
