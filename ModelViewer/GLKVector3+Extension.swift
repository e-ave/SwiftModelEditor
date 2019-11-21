//
//  GLKVector3+Extension.swift
//  ModelViewer
//
//  Created by temp on 3/25/17.
//  Copyright © 2017 eave. All rights reserved.
//

import Foundation
import GLKit

/// Various addons to make GLKVector3 easier to uses

extension GLKVector3 {
    public static let back: GLKVector3 = GLKVector3Make(0, 0, -1)
    public static let forward: GLKVector3 = GLKVector3Make(0, 0, 1)
    public static let down: GLKVector3 = GLKVector3Make(0, -1, 0)
    public static let up: GLKVector3 = GLKVector3Make(0, 1, 0)
    public static let left: GLKVector3 = GLKVector3Make(-1, 0, 0)
    public static let right: GLKVector3 = GLKVector3Make(1, 0, 0)
    public static let zero: GLKVector3 = GLKVector3Make(0, 0, 0)
    public static let one: GLKVector3 = GLKVector3Make(1, 1, 1)
}

extension GLKVector3 {
    
    public var normalized: GLKVector3 {
        return GLKVector3Normalize(self)
    }
}


extension GLKVector3 : Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: GLKVector3, rhs: GLKVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    public static func == (lhs: GLKVector3, rhs: Float32) -> Bool {
        return lhs.x == rhs && lhs.y == rhs && lhs.z == rhs
    }
}


extension GLKVector3 {
    
    static func * (lhs: GLKVector3, rhs : Float32) -> GLKVector3 {
        return GLKVector3MultiplyScalar(lhs, rhs)
    }

    static func * (lhs: GLKVector3, rhs : GLKVector3) -> GLKVector3 {
        return GLKVector3Multiply(lhs, rhs)
    }

    static func / (lhs: GLKVector3, rhs : Float32) -> GLKVector3 {
        return GLKVector3DivideScalar(lhs, rhs)
    }

    static func / (lhs: GLKVector3, rhs : GLKVector3) -> GLKVector3 {
        return GLKVector3Divide(lhs, rhs)
    }

    static func + (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
        return GLKVector3Add(lhs, rhs)
    }

    static func + (lhs: GLKVector3, rhs: Float32) -> GLKVector3 {
        return GLKVector3AddScalar(lhs, rhs)
    }

    static func - (lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
        return GLKVector3Subtract(lhs, rhs)
    }

    static func - (lhs: GLKVector3, rhs: Float32) -> GLKVector3 {
        return GLKVector3SubtractScalar(lhs, rhs)
    }

    static func += (lhs: inout GLKVector3, rhs: GLKVector3) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout GLKVector3, rhs: GLKVector3) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout GLKVector3, rhs: GLKVector3) {
        lhs = lhs * rhs
    }

    static func /= ( lhs: inout GLKVector3, rhs: GLKVector3) {
        lhs = lhs / rhs
    }
}
