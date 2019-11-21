//
//  ProceduralIcosphere.swift
//  ModelViewer
//
//  Created by Ethan Ave on 4/18/17.
//  Copyright © 2017 eave. All rights reserved.
//
// Ported from: http://wiki.unity3d.com/index.php/ProceduralPrimitives#C.23_-_IcoSphere
// https://creativecommons.org/licenses/by-sa/3.0/

import Foundation
import GLKit

final class ProceduralIcosphere : ProceduralPrimitive {
    
    var recursionLevel: Int = 1
    var radius: Float = 1.0
    
    
    override func generate() {
        
        var vertList: [GLKVector3] = []
        var middlePointIndexCache: [Int64 : Int] = [:]
        let t: Float = (1.0 + sqrt(5.0)) / 2.0
        
        vertList.append(GLKVector3Make(-1.0,  t,  0).normalized * radius)
        vertList.append(GLKVector3Make(1.0,  t,  0).normalized * radius);
        vertList.append(GLKVector3Make(-1.0, -t,  0).normalized * radius);
        vertList.append(GLKVector3Make( 1.0, -t,  0).normalized * radius);
        
        vertList.append(GLKVector3Make(0, -1.0,  t).normalized * radius);
        vertList.append(GLKVector3Make(0,  1.0,  t).normalized * radius);
        vertList.append(GLKVector3Make(0, -1.0, -t).normalized * radius);
        vertList.append(GLKVector3Make(0,  1.0, -t).normalized * radius);
        
        vertList.append(GLKVector3Make(t,  0, -1.0).normalized * radius);
        vertList.append(GLKVector3Make(t,  0,  1.0).normalized * radius);
        vertList.append(GLKVector3Make(-t,  0, -1.0).normalized * radius);
        vertList.append(GLKVector3Make(-t,  0,  1.0).normalized * radius);
        
        
        var faces: [TriangleIndices] = []
        
        // 5 faces around point 0
        faces.append(TriangleIndices(0, 11, 5))
        faces.append(TriangleIndices(0, 5, 1))
        faces.append(TriangleIndices(0, 1, 7))
        faces.append(TriangleIndices(0, 7, 10))
        faces.append(TriangleIndices(0, 10, 11))
        
        // 5 adjacent faces
        faces.append(TriangleIndices(1, 5, 9))
        faces.append(TriangleIndices(5, 11, 4))
        faces.append(TriangleIndices(11, 10, 2))
        faces.append(TriangleIndices(10, 7, 6))
        faces.append(TriangleIndices(7, 1, 8))
        
        // 5 faces around point 3
        faces.append(TriangleIndices(3, 9, 4))
        faces.append(TriangleIndices(3, 4, 2))
        faces.append(TriangleIndices(3, 2, 6))
        faces.append(TriangleIndices(3, 6, 8))
        faces.append(TriangleIndices(3, 8, 9))
        
        // 5 adjacent faces
        faces.append(TriangleIndices(4, 9, 5))
        faces.append(TriangleIndices(2, 4, 11))
        faces.append(TriangleIndices(6, 2, 10))
        faces.append(TriangleIndices(8, 6, 7))
        faces.append(TriangleIndices(9, 8, 1))
        
        // refine triangles
        for _ in 0 ..< recursionLevel {
            var faces2: [TriangleIndices] = []
            for tri in faces {
                // replace triangle by 4 triangles
                let a: Int = ProceduralIcosphere.getMiddlePoint(p1: tri.v1, p2: tri.v2, vertices: &vertList, cache: &middlePointIndexCache, radius: radius)
                let b: Int = ProceduralIcosphere.getMiddlePoint(p1: tri.v2, p2: tri.v3, vertices: &vertList, cache: &middlePointIndexCache, radius: radius)
                let c: Int = ProceduralIcosphere.getMiddlePoint(p1: tri.v3, p2: tri.v1, vertices: &vertList, cache: &middlePointIndexCache, radius: radius)
                
                faces2.append(TriangleIndices(tri.v1, a, c))
                faces2.append(TriangleIndices(tri.v2, b, a))
                faces2.append(TriangleIndices(tri.v3, c, b))
                faces2.append(TriangleIndices(a, b, c))
            }
            faces = faces2;
        }
        
        var tris: [Int] = []
        for i in 0 ..< faces.count {
            tris.append(faces[i].v1)
            tris.append(faces[i].v2)
            tris.append(faces[i].v3)
        }
        
        var normals: [GLKVector3] = []
        for i in 0 ..< vertList.count {
            normals.append(vertList[i].normalized)
        }
        
        
        mesh = Primitive()
        mesh?.vertices = vertList
        mesh?.triangleIndices = tris
        mesh?.normals = normals
        //mesh?.uv = uvs
        
    }
    
    
    private static func getMiddlePoint(p1: Int, p2: Int, vertices: inout [GLKVector3], cache: inout [Int64 : Int], radius: Float) -> Int {
        let firstIsSmaller = p1 < p2
        let smallerIndex: Int64 = Int64(firstIsSmaller ? p1 : p2)
        let greaterIndex: Int64 = Int64(firstIsSmaller ? p2 : p1)
        let key: Int64 = (smallerIndex << 32) + greaterIndex
        
        
        if let ret = cache[key] {
            return ret
        }
        
        let point1: GLKVector3 = vertices[p1]
        let point2: GLKVector3 = vertices[p2]
        let middle: GLKVector3 = (point1 + point2) / 2.0
        
        let i: Int = vertices.count
        vertices.append(GLKVector3Normalize(middle).normalized * radius)
        cache[key] = i
        
        
        return i
    }
    
}


private struct TriangleIndices {
    public var v1: Int
    public var v2: Int
    public var v3: Int
    
    init(_ v1: Int, _ v2: Int, _ v3: Int) {
        self.v1 = v1
        self.v2 = v2
        self.v3 = v3
    }
}
