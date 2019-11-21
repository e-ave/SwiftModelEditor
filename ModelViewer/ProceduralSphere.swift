//
//  ProceduralSphere.swift
//  ModelViewer
//
//  Created by Ethan Ave on 4/17/17.
//  Copyright © 2017 eave. All rights reserved.
//
// Ported from: http://wiki.unity3d.com/index.php/ProceduralPrimitives#C.23_-_Sphere
// https://creativecommons.org/licenses/by-sa/3.0/

import Foundation
import GLKit

final class ProceduralSphere : ProceduralPrimitive {
    
    
    let radius: Float
    let nbLong: Int
    let nbLat: Int
    
    
    init(radius: Float = 1.0, longitudeCount nbLong: Int = 24, latitudeCount nbLat: Int = 16) {
        self.radius = radius
        self.nbLong = nbLong
        self.nbLat = nbLat
    }
    
    override func generate() {
        // region Vertices
        var vertices: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: (nbLong + 1) * nbLat + 2)
        let _pi: Float = Float.pi
        let _2pi: Float = _pi * 2.0
        
        vertices[0] = GLKVector3.up * radius
        for lat in 0 ..< nbLat {
            let a1: Float = _pi * Float(lat + 1) / Float(nbLat + 1)
            let sin1: Float = sin(a1)
            let cos1: Float = cos(a1)
            
            for lon in 0 ... nbLong {
                let a2: Float = _2pi * Float(lon == nbLong ? 0 : lon) / Float(nbLong)
                let sin2: Float = sin(a2)
                let cos2: Float = cos(a2)
                
                vertices[lon + lat * (nbLong + 1) + 1] = GLKVector3Make(sin1 * cos2, cos1, sin1 * sin2) * radius
            }
        }
        vertices[vertices.count - 1] = GLKVector3.up * -radius
        // endregion
        
        // region Normales
        var normals: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: vertices.count)
        for n in 0 ..< vertices.count {
            normals[n] = GLKVector3Normalize(vertices[n])
        }
        // endregion
        
        // region UVs
        var uvs: [GLKVector2] = [GLKVector2](repeating: GLKVector2.zero, count: vertices.count)
        uvs[0] = GLKVector2.up
        uvs[uvs.count - 1] = GLKVector2.zero
        for lat in 0 ..< nbLat {
            for lon in 0 ... nbLong {
                uvs[lon + lat * (nbLong + 1) + 1] = GLKVector2Make(Float(lon) / Float(nbLong), 1.0 - Float(lat+1) / Float(nbLat + 1))
            }
        }
        
        // region Triangles
        let nbFaces: Int = vertices.count
        let nbTriangles: Int = nbFaces * 2
        let nbIndices = nbTriangles * 3
        
        var triangles: [Int] = [Int](repeating: 0, count: nbIndices)
        
        //Top Cap
        var i: Int = 0
        for lon in 0 ..< nbLong {
            triangles[i++] = lon + 2
            triangles[i++] = lon + 1
            triangles[i++] = 0
        }
        
        //Middle
        for lat in 0 ..< nbLat - 1 {
            for lon in 0 ..< nbLong {
                let current: Int = lon + lat * (nbLong + 1) + 1
                let next: Int = current + nbLong + 1
                
                triangles[i++] = current
                triangles[i++] = current + 1
                triangles[i++] = next + 1
                
                triangles[i++] = current
                triangles[i++] = next + 1
                triangles[i++] = next
            }
        }
        
        //Bottom Cap
        for lon in 0 ..< nbLong {
            triangles[i++] = vertices.count - 1
            triangles[i++] = vertices.count - (lon + 2) - 1
            triangles[i++] = vertices.count - (lon + 1) - 1
        }
        mesh = Primitive()
        mesh?.vertices = vertices
        mesh?.normals = normals
        mesh?.triangleIndices = triangles
        mesh?.uv = uvs
        
    }
    
}
