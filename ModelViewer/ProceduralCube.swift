//
//  ProceduralCube.swift
//  ModelViewer
//
//  Created by temp on 3/25/17.
//  Copyright © 2017 eave. All rights reserved.
//
// Ported from: http://wiki.unity3d.com/index.php/ProceduralPrimitives#C.23_-_Box
// https://creativecommons.org/licenses/by-sa/3.0/

import Foundation
import GLKit

final class ProceduralCube : ProceduralPrimitive {
    
    var length: Float
    var width: Float
    var height: Float

    init(length: Float = 1.0, width: Float = 1.0, height: Float = 1.0) {
        self.length = length
        self.width = width
        self.height = height
    }
    
    override internal func generate() {
        // Vertices
        let p0: GLKVector3 = GLKVector3Make(-length * 0.5,	-width * 0.5, height * 0.5)
        let p1: GLKVector3 = GLKVector3Make(length * 0.5, -width * 0.5, height * 0.5)
        let p2: GLKVector3 = GLKVector3Make(length * 0.5, -width * 0.5, -height * 0.5)
        let p3: GLKVector3 = GLKVector3Make(-length * 0.5,-width * 0.5, -height * 0.5)
        
        let p4: GLKVector3 = GLKVector3Make(-length * 0.5, width * 0.5,  height * 0.5)
        let p5: GLKVector3 = GLKVector3Make(length * 0.5, width * 0.5,  height * 0.5)
        let p6: GLKVector3 = GLKVector3Make(length * 0.5, width * 0.5,  -height * 0.5)
        let p7: GLKVector3 = GLKVector3Make(-length * 0.5, width * 0.5,  -height * 0.5)
        
        
        let vertices: [GLKVector3] = [
            // Bottom
            p0, p1, p2, p3,
            
            // Left
            p7, p4, p0, p3,
            
            // Front
            p4, p5, p1, p0,
            
            // Back
            p6, p7, p3, p2,
            
            // Right
            p5, p6, p2, p1,
            
            // Top
            p7, p6, p5, p4
        ]
        
        /* // Barycentric corners
         let l1: GLKVector3 = GLKVector3Make(1, 0, 0)
         let l2: GLKVector3 = GLKVector3Make(0, 1, 0)
         let l3: GLKVector3 = GLKVector3Make(0, 0, 1)
         
         let barycentric: [GLKVector3] = [
         // Bottom
         l1, l2, l1, l3,
         
         // Left
         l3, l1, l3, l2,
         
         // Front
         l2, l3, l2, l1,
         
         // Back
         l1, l2, l1, l3,
         
         // Right
         l3, l1, l3, l2,
         
         // Top
         l2, l3, l2, l1
         ]*/
        
        // Normals
        
        let up: GLKVector3 = GLKVector3.up
        let down: GLKVector3 = GLKVector3.down
        let front: GLKVector3 = GLKVector3.forward
        let back: GLKVector3 = GLKVector3.back
        let left: GLKVector3 = GLKVector3.left
        let right: GLKVector3 = GLKVector3.right
        
        let normals: [GLKVector3] = [
            // Bottom
            down, down, down, down,
            
            // Left
            left, left, left, left,
            
            // Front
            front, front, front, front,
            
            // Back
            back, back, back, back,
            
            // Right
            right, right, right, right,
            
            // Top
            up, up, up, up
        ]
        
        //UVs
        let _00: GLKVector2 = GLKVector2.zero
        let _10: GLKVector2 = GLKVector2.right
        let _01: GLKVector2 = GLKVector2.up
        let _11: GLKVector2 = GLKVector2.one
        
        let uvs: [GLKVector2] = [
            // Bottom
            _11, _01, _00, _10,
            
            // Left
            _11, _01, _00, _10,
            
            // Front
            _11, _01, _00, _10,
            
            // Back
            _11, _01, _00, _10,
            
            // Right
            _11, _01, _00, _10,
            
            // Top
            _11, _01, _00, _10,
            ]
        
        // Triangles
        let triangles: [Int] = [
            // Bottom
            3, 1, 0,
            3, 2, 1,
            
            // Left
            3 + 4 * 1, 1 + 4 * 1, 0 + 4 * 1,
            3 + 4 * 1, 2 + 4 * 1, 1 + 4 * 1,
            
            // Front
            3 + 4 * 2, 1 + 4 * 2, 0 + 4 * 2,
            3 + 4 * 2, 2 + 4 * 2, 1 + 4 * 2,
            
            // Back
            3 + 4 * 3, 1 + 4 * 3, 0 + 4 * 3,
            3 + 4 * 3, 2 + 4 * 3, 1 + 4 * 3,
            
            // Right
            3 + 4 * 4, 1 + 4 * 4, 0 + 4 * 4,
            3 + 4 * 4, 2 + 4 * 4, 1 + 4 * 4,
            
            // Top
            3 + 4 * 5, 1 + 4 * 5, 0 + 4 * 5,
            3 + 4 * 5, 2 + 4 * 5, 1 + 4 * 5,
            
            ]
        mesh = Primitive()
        mesh?.vertices = vertices
        mesh?.normals = normals
        mesh?.triangleIndices = triangles
        mesh?.uv = uvs
        
        
    }

}
