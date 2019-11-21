//
//  RayTest.swift
//  ModelViewer
//
//  Created by Ethan Ave on 3/21/17.
//  Copyright © 2017 eave. All rights reserved.
//

import Foundation
import GLKit

class RayTest {
    
    private static let EPSILON: Float = 0.00001
    
    /// Calculates the area of a triangle represented by three vertices
    public static func triangleArea(_ a: GLKVector3, _ b: GLKVector3, _ c: GLKVector3) -> Float {
        // Since |a X b| is the area of the parallelogram spanned by vectors a and b,
        // we can get that from our normal vector function and divide it by 2 to get
        // the area of the triangle
        let crossed = getNormalVector(a, b, c)
        return GLKVector3Length(crossed) / 2
    }
    
    /// Calculates a vector normal to the plane containing three points
    /// The resulting normal vector <a, b, c> then creates the plane ax + by + cz = t
    public static func getNormalVector(_ a: GLKVector3, _ b: GLKVector3, _ c: GLKVector3) -> GLKVector3 {
        // This is pretty simple. We just need the cross product
        // of two vectors that are inside the plane.
        // Since we have three points inside the plane, we can just
        // create two vectors from them.
        let ab: GLKVector3 = b - a
        let ac: GLKVector3 = c - a
        return GLKVector3CrossProduct(ab, ac)
    }
    
    /// Checks if a ray intersects with a triangle in 3D space and returns
    /// the point at which they do. Nil will be returned if there is no intersection.
    /// This method uses basic linear algebra to solve the problem by finding the plane
    /// in which the triangle resides and the point at which the ray intersects with
    /// the plane. It is therefore slower than the other methods, but also easier to
    /// visualize and understand mathematically.
    ///
    /// - parameters:
    ///     - origin: The origin of the ray
    ///     - direction: The direction of the ray
    ///     - vertexA: The first vertex of the triangle
    ///     - vertexB: The second vertex of the triangle
    ///     - vertexC: The third vertex of the triangle
    /// - returns: The point at which the ray and the triangle intersect or nil.
    public static func algebraicTest(origin: GLKVector3, direction: GLKVector3, vertexA: GLKVector3, vertexB: GLKVector3, vertexC: GLKVector3) -> GLKVector3? {
        
        // First need to imagine the triangle as a plane, extending infinitely in all directions.
        // To find the equation of the plane, we can simply find a vector normal to the plane
        // containing all three points.
        
        // A vector orthogonal to the plane containing the triangle vertices a, b, c
        //              ^
        //              |
        //      ________|___________
        //     /   b    |_         /
        //    /         | |       /
        //   /  a    c           /
        //  /___________________/
        let plane = getNormalVector(vertexA, vertexB, vertexC)
        
        // Now imagine the ray defined by the direction vector and origin vector as
        // a line extending infinitely in both directions rather than just one direction.
        // We need to find the point at which the plane and the line intersect
        // There are three possibilities:
        // 1. The line is parallel to the plane (no intersection)
        // 2. The line is contained by the plane (infinite intersection)
        // 3. The line intersects the plane (one point of intersection)
        
        
        // First, we'll check when the line given by the ray is parallel to the plane.
        // Since the dot product of two vectors is zero if and only if they are orthogonal,
        // we can tell that the line and the plane are parallel if the line and the normal
        // vector of the plane are orthogonal. Visualized below.
        //
        //              ^
        //              |---->
        //      ________|___________
        //     /        |_         /
        //    /         | |       /
        //   /                   /
        //  /___________________/
        //
        // This also, consequently, takes care of our second case when the line is contained
        // by the plane, since any time the line is inside the plane, it would also be parallel
        // to it.
        let dot: Float = GLKVector3DotProduct(direction, plane)
        if(dot == 0) {
            return nil
        }
        
        // Now that we've taken care of our special cases, all there is to do is check when the line
        // intersects the plane (it must).
        
        // The equation for a line is as follows: <x0,y0,z0> + t<a,b,c> where <x0,y0,z0> is an initial
        // point on the line and <a,b,c> is a vector parallel to the line. Since we have a ray, that means
        // we have <x0,y0,z0> (the origin) and t<a,b,c> (the direction). That means we need to find the
        // t at which the plane and line intersect.
        
        // This visualization is too complex to draw in ASCII, but just trust me, it works.
        // It's just working with algebra around the equation of a plane.
        let d: Float = GLKVector3DotProduct(plane, vertexA)//D in the equation of a plane
        let t: Float = (d - GLKVector3DotProduct(plane, origin)) / dot
        //t = (-n dot w) / (n dot u)
        
        // Now check for intersection in the opposite direction of the ray
        // since we're dealing with a line in the calculations
        if(t < 0) {
            return nil
        }
        
        // Now we finally have our intersection point by plugging in the equation of a line at t.
        let intersection: GLKVector3 = origin + direction * t
        
        
        // Let's take a triangle with the point + inside of it.
        // We can split the triangle into 3 triangles from the point to the vertices
        //           /.\
        //          / . \
        //         /  .  \
        //        /   +   \
        //       /   . .   \
        //      /  .     .  \
        //     / .         . \
        //    /._____________.\
        //
        // If we take the areas of the 3 separate triangles and they equal
        // the area of the complete triangle, then the point + must be inside the triangle.
        // However, if the areas do not equal the area of the complete triangle, the point
        // CANNOT be inside the triangle. It is easy to understand with the picture below
        //           /.\
        //          /   \.
        //         /     \  .
        //        /       \  .+
        //       /        .\  .
        //      /      .    \ .
        //     /    .        \.
        //    /.______________\
        //
        //
        //
        
        // Area of the complete triangle
        let full: Float = triangleArea(vertexA, vertexB, vertexC)
        
        // The three sub triangles
        let sub1: Float = triangleArea(vertexA, vertexB, intersection)
        let sub2: Float = triangleArea(vertexB, vertexC, intersection)
        let sub3: Float = triangleArea(vertexA, vertexC, intersection)
        
        // Now subtract the sum of the sub triangle areas from the area of the full triangle
        // We can't check if they are exactly the same due to rounding error
        if(abs(full - (sub1 + sub2 + sub3)) < RayTest.EPSILON) {
            return intersection
        }
        return nil
        
    }
}
