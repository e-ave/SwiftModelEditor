//
//  ProceduralPlane.swift
//  ModelViewer
//
//  Created by Ethan Ave on 4/18/17.
//  Copyright © 2017 eave. All rights reserved.
//
// Ported from: http://wiki.unity3d.com/index.php/ProceduralPrimitives#C.23_-_Plane
// https://creativecommons.org/licenses/by-sa/3.0/

import Foundation
import GLKit

final class ProceduralPlane : ProceduralPrimitive {
    
    var length: Float = 1.0
    var width: Float = 1.0
    var resX: Int = 2// 2 minimum
    var resZ: Int = 2
    
    override func generate() {
        //region Vertices
        var vertices: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: resX * resZ)
        for z in 0 ..< resZ {
            // [ -length / 2, length / 2 ]
            let zPos: Float = (Float(z) / Float(resZ - 1) - 0.5) * length
            for x in 0 ..< resX {
                // [ -width / 2, width / 2 ]
                let xPos: Float = (Float(x) / Float(resX - 1) - 0.5) * width
                vertices[x + z * resX] = GLKVector3Make(xPos, 0, zPos)
            }
        }
        //endregion
        
        //region Normales
        var normals: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: vertices.count)
        
        for n in 0 ..< normals.count {
            normals[n] = GLKVector3.up
        }
        //endregion
        
        //region UVs
        var uvs: [GLKVector2] = [GLKVector2](repeating: GLKVector2.zero, count: vertices.count)
        for v in 0 ..< resZ {
            for u in 0 ..< resX {
                uvs[ u + v * resX ] = GLKVector2Make(Float(u) / Float(resX - 1), Float(v) / Float(resZ - 1))
            }
        }
        //endregion
        
        //region Triangles
        let nbFaces: Int = (resX - 1) * (resZ - 1)
        var triangles: [Int] = [Int](repeating: 0, count: nbFaces * 6)
        var t: Int = 0
        for face in 0 ..< nbFaces {
            // Retrieve lower left corner from face ind
            let i: Int = face % (resX - 1) + (face / (resZ - 1) * resX)
            
            triangles[t++] = i + resX
            triangles[t++] = i + 1
            triangles[t++] = i
            
            triangles[t++] = i + resX
            triangles[t++] = i + resX + 1
            triangles[t++] = i + 1
        }
        //endregion
        
        mesh = Primitive()
        mesh?.vertices = vertices
        mesh?.normals = normals
        mesh?.triangleIndices = triangles
        mesh?.uv = uvs
        
    }
    
}
