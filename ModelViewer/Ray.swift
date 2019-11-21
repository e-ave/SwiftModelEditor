//
//  Ray.swift
//  ModelViewer
//
//  Created by eave on 3/22/17.
//  Copyright © 2017 eave. All rights reserved.
//

import Foundation
import GLKit

/// A simple class that represents a ray by an origin and direction
class Ray {
    
    private var direction: GLKVector3
    private var origin: GLKVector3
    private var dragging: Bool = false
    
    init(origin: GLKVector3 = GLKVector3Make(0, 0, 0), direction: GLKVector3 = GLKVector3Make(0, 0, 0)) {
        self.origin = origin
        self.direction = direction
    }
    
    /// Sets the ray's direction
    public func setDirection(_ direction: GLKVector3) {
        self.direction = direction
    }
    
    /// Gets the ray's direction
    public func getDirection() -> GLKVector3 {
        return self.direction
    }
    
    /// Sets the ray's origin
    public func setOrigin(_ origin: GLKVector3) {
        self.origin = origin
    }
    
    /// Get the ray's origin
    public func getOrigin() -> GLKVector3 {
        return self.origin
    }
    
    /// Set if the movement is dragging. This is not
    /// strictly related to the ray itself but the movement
    /// of the user
    public func setDragging(_ dragging: Bool) {
        self.dragging = dragging
    }
    
    /// Get if the movement is dragging. This is not
    /// strictly related to the ray itself but the movement
    /// of the user
    public func getDragging() -> Bool {
        return dragging
    }
}
