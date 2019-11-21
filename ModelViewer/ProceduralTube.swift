//
//  ProceduralTube.swift
//  ModelViewer
//
//  Created by temp on 3/25/17.
//  Copyright © 2017 eave. All rights reserved.
//
// Ported from: http://wiki.unity3d.com/index.php/ProceduralPrimitives#C.23_-_Tube
// https://creativecommons.org/licenses/by-sa/3.0/

import Foundation
import GLKit

final class ProceduralTube : ProceduralPrimitive {
    
    let height: Float = 1.0
    let nbSides: Int = 24
    
    // Outter shell is at radius1 + radius2 / 2, inner shell at radius1 - radius2 / 2
    let bottomRadius1: Float = 0.5
    let bottomRadius2: Float = 0.15
    let topRadius1: Float = 0.5
    let topRadius2: Float = 0.15
    
    override func generate() {

        
        let nbVerticesCap: Int = nbSides * 2 + 2
        let nbVerticesSides: Int = nbSides * 2 + 2
        // Vertices
        
        // bottom + top + sides
        var vertices: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: nbVerticesCap * 2 + nbVerticesSides * 2)
        var vert: Int = 0
        let _2pi: Float = Float.pi * 2.0
        
        // Bottom cap
        var sideCounter: Int = 0
        while vert < nbVerticesCap {
            sideCounter = sideCounter == nbSides ? 0 : sideCounter
            
            let r1: Float = Float(sideCounter++) / Float(nbSides) * _2pi
            let cosine: Float = cos(r1)
            let sine: Float = sin(r1)
            vertices[vert++] = GLKVector3Make(cosine * (bottomRadius1 - bottomRadius2 * 0.5), 0, sine * (bottomRadius1 - bottomRadius2 * 0.5))
            vertices[vert++] = GLKVector3Make(cosine * (bottomRadius1 + bottomRadius2 * 0.5), 0, sine * (bottomRadius1 + bottomRadius2 * 0.5))
        }
        
        // Top cap
        sideCounter = 0
        while vert < nbVerticesCap * 2 {
            sideCounter = sideCounter == nbSides ? 0 : sideCounter
            
            let r1: Float = Float(sideCounter++) / Float(nbSides) * _2pi
            let cosine: Float = cos(r1)
            let sine: Float = sin(r1)
            vertices[vert++] = GLKVector3Make(cosine * (topRadius1 - topRadius2 * 0.5), height, sine * (topRadius1 - topRadius2 * 0.5))
            vertices[vert++] = GLKVector3Make(cosine * (topRadius1 + topRadius2 * 0.5), height, sine * (topRadius1 + topRadius2 * 0.5))
        }
        
        // Sides (out)
        sideCounter = 0
        while vert < nbVerticesCap * 2 + nbVerticesSides {
            sideCounter = sideCounter == nbSides ? 0 : sideCounter
            
            let r1: Float = Float(sideCounter++) / Float(nbSides) * _2pi
            let cosine: Float = cos(r1)
            let sine: Float = sin(r1)
            
            vertices[vert++] = GLKVector3Make(cosine * (topRadius1 + topRadius2 * 0.5), height, sine * (topRadius1 + topRadius2 * 0.5))
            vertices[vert++] = GLKVector3Make(cosine * (bottomRadius1 + bottomRadius2 * 0.5), 0, sine * (bottomRadius1 + bottomRadius2 * 0.5))
        }
        
        // Sides (in)
        sideCounter = 0
        while vert < vertices.count {
            sideCounter = sideCounter == nbSides ? 0 : sideCounter
            
            let r1: Float = Float(sideCounter++) / Float(nbSides) * _2pi
            let cosine: Float = cos(r1)
            let sine: Float = sin(r1)
            
            vertices[vert++] = GLKVector3Make(cosine * (topRadius1 - topRadius2 * 0.5), height, sine * (topRadius1 - topRadius2 * 0.5))
            vertices[vert++] = GLKVector3Make(cosine * (bottomRadius1 - bottomRadius2 * 0.5), 0, sine * (bottomRadius1 - bottomRadius2 * 0.5))
        }
        
        // Normals
        
        // bottom + top + sides
        var normals: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: vertices.count)
        vert = 0
        
        // Bottom cap
        while vert < nbVerticesCap {
            normals[vert++] = GLKVector3.down
        }
        
        // Top cap
        while vert < nbVerticesCap * 2 {
            normals[vert++] = GLKVector3.up
        }
        
        // Sides (out)
        sideCounter = 0
        while vert < nbVerticesCap * 2 + nbVerticesSides {
            sideCounter = sideCounter == nbSides ? 0 : sideCounter
            
            let r1: Float = Float(sideCounter++) / Float(nbSides) * _2pi
            
            normals[vert] = GLKVector3Make(cos(r1), 0, sin(r1))
            normals[vert + 1] = normals[vert]
            vert += 2
        }
        
        // Sides (in)
        sideCounter = 0
        while vert < vertices.count {
            sideCounter = sideCounter == nbSides ? 0 : sideCounter
            
            let r1: Float = Float(sideCounter++) / Float(nbSides) * _2pi
            
            normals[vert] = GLKVector3Make(-cos(r1), 0, -sin(r1))
            normals[vert + 1] = normals[vert]
            vert += 2
        }
        
        // UVs
        var uvs: [GLKVector2] = [GLKVector2](repeating: GLKVector2.zero, count: vertices.count)
        vert = 0
        // Bottom cap
        sideCounter = 0
        while vert < nbVerticesCap {
            let t: Float = Float(sideCounter++) / Float(nbSides)
            uvs[vert++] = GLKVector2Make(0, t)
            uvs[vert++] = GLKVector2Make(1, t)
        }
        
        // Top cap
        sideCounter = 0
        while vert < nbVerticesCap * 2 {
            let t: Float = Float(sideCounter++) / Float(nbSides)
            uvs[vert++] = GLKVector2Make(0, t)
            uvs[vert++] = GLKVector2Make(1, t)
        }
        
        // Sides (out)
        sideCounter = 0
        while vert < nbVerticesCap * 2 + nbVerticesSides {
            let t: Float = Float(sideCounter++) / Float(nbSides)
            uvs[vert++] = GLKVector2Make(t, 0)
            uvs[vert++] = GLKVector2Make(t, 1)
        }
        
        // Sides (in)
        sideCounter = 0
        while vert < vertices.count {
            let t: Float = Float(sideCounter++) / Float(nbSides)
            uvs[vert++] = GLKVector2Make(t, 0)
            uvs[vert++] = GLKVector2Make(t, 1)
        }
        
        // Triangles
        let nbFace: Int = nbSides * 4
        let nbTriangles: Int = nbFace * 2
        let nbIndexes: Int = nbTriangles * 3
        var triangles: [Int] = [Int](repeating: 0, count: nbIndexes)
        // Bottom cap
        var i: Int = 0
        sideCounter = 0
        while sideCounter < nbSides {
            let current: Int = sideCounter * 2
            let next: Int = sideCounter * 2 + 2
            
            triangles[i++] = next + 1
            triangles[i++] = next
            triangles[i++] = current
            
            triangles[i++] = current + 1
            triangles[i++] = next + 1
            triangles[i++] = current
            
            sideCounter += 1
        }
        
        // Top cap
        while sideCounter < nbSides * 2 {
            let current: Int = sideCounter * 2 + 2
            let next: Int = sideCounter * 2 + 4
            
            triangles[i++] = current
            triangles[i++] = next
            triangles[i++] = next + 1
            
            triangles[i++] = current
            triangles[i++] = next + 1
            triangles[i++] = current + 1
            
            sideCounter += 1
        }
        
        // Sides (out)
        while sideCounter < nbSides * 3 {
            let current: Int = sideCounter * 2 + 4
            let next: Int = sideCounter * 2 + 6
            
            triangles[i++] = current
            triangles[i++] = next
            triangles[i++] = next + 1
            
            triangles[i++] = current
            triangles[i++] = next + 1
            triangles[i++] = current + 1
            
            sideCounter += 1
        }
        
        
        // Sides (in)
        while sideCounter < nbSides * 4 {
            let current: Int = sideCounter * 2 + 6
            let next: Int = sideCounter * 2 + 8
            
            triangles[i++] = next + 1
            triangles[i++] = next
            triangles[i++] = current
            
            triangles[i++] = current + 1
            triangles[i++] = next + 1
            triangles[i++] = current
            
            sideCounter += 1
        }
        mesh = Primitive()
        mesh?.vertices = vertices
        mesh?.normals = normals
        mesh?.triangleIndices = triangles
        mesh?.uv = uvs
        
    }
    
}
