//
//  ProceduralCone.swift
//  ModelViewer
//
//  Created by temp on 3/25/17.
//  Copyright © 2017 eave. All rights reserved.
//
// Ported from: http://wiki.unity3d.com/index.php/ProceduralPrimitives#C.23_-_Cone
// https://creativecommons.org/licenses/by-sa/3.0/

import Foundation
import GLKit

class ProceduralCone : ProceduralPrimitive {
    var height: Float = 1.0
    var bottomRadius: Float = 1.25
    var topRadius: Float = 0.05
    var nbSides: Int = 22
    let nbHeightSeg: Int = 1 // Not implemented yet
    
    
    init(sides: Int = 20, height: Float = 1.0, topRadius: Float = 0.0, bottomRadius: Float = 1.0) {
        self.nbSides = sides
        self.height = height
        self.topRadius = topRadius
        self.bottomRadius = bottomRadius
    }
    
    override internal func generate() {
        
        let nbVerticesCap: Int = nbSides + 1
        // Vertices
        
        // bottom + top + sides
        let count: Int = nbVerticesCap + nbVerticesCap + nbSides * nbHeightSeg * 2 + 2
        var vertices: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: count)
        var vert: Int = 0
        let _2pi: Float = Float.pi * 2.0
        
        // Bottom cap
        vertices[vert++] = GLKVector3.zero
        while vert <= nbSides {
            let rad: Float = Float(vert) / Float(nbSides) * _2pi
            vertices[vert++] = GLKVector3Make(cos(rad) * bottomRadius, 0, sin(rad) * bottomRadius)
        }
        
        // Top cap
        vertices[vert++] = GLKVector3Make(0, height, 0)
        while vert <= nbSides * 2 + 1 {
            let rad: Float = Float(vert - nbSides - 1)  / Float(nbSides) * _2pi
            vertices[vert++] = GLKVector3Make(cos(rad) * topRadius, height, sin(rad) * topRadius)
        }
        
        // Sides
        var v: Int = 0
        while vert <= vertices.count - 4 {
            let rad: Float = Float(v) / Float(nbSides) * _2pi
            vertices[vert++] = GLKVector3Make(cos(rad) * topRadius, height, sin(rad) * topRadius)
            vertices[vert++] = GLKVector3Make(cos(rad) * bottomRadius, 0, sin(rad) * bottomRadius)
            v += 1
        }
        vertices[vert++] = vertices[nbSides * 2 + 2]
        vertices[vert++] = vertices[nbSides * 2 + 3]
        
        // Normals
        
        // bottom + top + sides
        var normals: [GLKVector3] = [GLKVector3](repeating: GLKVector3.zero, count: count)
        vert = 0
        
        // Bottom cap
        while vert <= nbSides {
            normals[vert++] = GLKVector3.down
        }
        
        // Top cap
        while vert <= nbSides * 2 + 1  {
            normals[vert++] = GLKVector3.up
        }
        
        // Sides
        v = 0
        while vert <= vertices.count - 4 {
            let rad: Float = Float(v) / Float(nbSides) * _2pi
            let cosine: Float = cos(rad)
            let sine: Float = sin(rad)
            
            normals[vert] = GLKVector3Make(cosine, 0, sine)
            normals[vert + 1] = normals[vert]
            vert += 2
            v += 1
        }
        normals[vert++] = normals[nbSides * 2 + 2 ]
        normals[vert++] = normals[nbSides * 2 + 3 ]
        
        
        // UVs
        var uvs: [GLKVector2] = [GLKVector2](repeating: GLKVector2.zero, count: count)
        
        // Bottom cap
        var u: Int = 0
        uvs[u++] = GLKVector2Make(0.5, 0.5)
        while u <= nbSides {
            let rad: Float = Float(u) / Float(nbSides) * _2pi
            uvs[u++] = GLKVector2Make(cos(rad) * 0.5 + 0.5, sin(rad) * 0.5 + 0.5)
        }
        
        // Top cap
        uvs[u++] = GLKVector2Make(0.5, 0.5)
        while u <= nbSides * 2 + 1 {
            let rad: Float = Float(u) / Float(nbSides) * _2pi
            uvs[u++] = GLKVector2Make(cos(rad) * 0.5 + 0.5, sin(rad) * 0.5 + 0.5)
        }
        
        // Sides
        var u_sides: Int = 0
        while u <= uvs.count - 4 {
            let t: Float = Float(u_sides) / Float(nbSides)
            uvs[u++] = GLKVector2Make(t, 1)
            uvs[u++] = GLKVector2Make(t, 0)
            u_sides += 1
        }
        uvs[u++] = GLKVector2.one
        uvs[u++] = GLKVector2.right
        
        // Triangles
        let nbTriangles: Int = nbSides + nbSides + nbSides * 2
        var triangles: [Int] = [Int](repeating: 0, count: nbTriangles * 3 + 3)
        // Bottom cap
        var tri: Int = 0
        var i: Int = 0
        while tri < nbSides - 1 {
            triangles[i++] = 0
            triangles[i++] = tri + 1
            triangles[i++] = tri + 2
            tri += 1
        }
        triangles[i++] = 0
        triangles[i++] = tri + 1
        triangles[i++] = 1
        tri += 1
        
        // Top cap
        //tri++
        while tri < nbSides * 2 {
            triangles[i++] = tri + 2
            triangles[i++] = tri + 1
            triangles[i++] = nbVerticesCap
            tri += 1
        }
        
        triangles[i++] = nbVerticesCap + 1
        triangles[i++] = tri + 1
        triangles[i++] = nbVerticesCap
        tri += 2
        
        // Sides
        while tri <= nbTriangles  {
            triangles[ i++] = tri + 2
            triangles[ i++] = tri + 1
            triangles[ i++] = tri + 0
            tri += 1
            
            triangles[ i++] = tri + 1
            triangles[ i++] = tri + 2
            triangles[ i++] = tri + 0
            tri += 1
        }
        
        mesh = Primitive()
        mesh?.vertices = vertices
        mesh?.normals = normals
        mesh?.triangleIndices = triangles
        mesh?.uv = uvs
    }
}
